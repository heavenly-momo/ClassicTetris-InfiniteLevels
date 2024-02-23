--[[
	~-------------------------------------------------------------------------------~
	Classic Tetris: Infinite Levels ~ An FCEUX script by momotsuki vǫl'gureschnxyzxyz
	~-------------------------------------------------------------------------------~
	
	This script alters Tetris' A-Type mode such that rather than
	rolling over to level 0 after level 255, it continues
	indefinitely to levels 256 and beyond.

	All levels after level 255 have random palettes, creating
	similar visuals to the "colors" glitch, but
	far more varied and unpredictable.

	This script also patches the ROM to prevent crashes from
	occurring at high levels as they do in the unaltered game.
	
	Most probably won't get much use out of this script,
	but if you're a TASer, AI, or god, then please enjoy it! <3
	
	~-------------------------------------------------------------------------------~
	Don't run this script! Run InfiniteLevels-Run.lua or call this script in another!
	~-------------------------------------------------------------------------------~
]]--


function InfiniteLevels()
	--[[
		Relevant memory addresses.
	]]--

	local isingame = 5
	local isbtype = 193

	local leveladdr = 68
	local levelmirroraddr = 100
	local startinglevel = 71

	local rng = 23

	local color0a = 16136
	local color0b = 16152
	local color1a = 16137
	local color1b = 16153
	local color2a = 16138
	local color2b = 16154
	local color3a = 16139
	local color3b = 16155


	--[[
		Two pools of colors to randomly select from.
		One includes black (13/0x0D,) the other doesn't.
	]]--

	local colors = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61}
	local colorsnoblack = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61}


	--[[
		Misc. variables.
	]]--

	local timer = 60
	local extralevels = 0
	local level0completed = false
	local hassetlevel = false
	local hasusedblack = false
	local romhash = ""

	--[[
		Function for writing to the PPU.
		Stolen from https://stackoverflow.com/a/43485738.
	]]--

	local function writeppu(address, value)
		memory.writebyte(8193, 0)
		memory.readbyte(8194)
		memory.writebyte(8198, math.floor(address / 256))
		memory.writebyte(8198, address % 256)
		memory.writebyte(8199, value)
		memory.writebyte(8193, 30)
	end


	--[[
		Function for selecting a random color from the NES' palette,
		being mindful to avoid using black more than once
		as that could result in invisible pieces.
		
		Lua's random function seems to be kind of atrocious,
		so some stuff is being done here to try and force it
		to "shake the bag" a bit more, so to speak.
		
		Also, it's done in such a way that when playing back
		a movie/"TAS," the colors should be the same every time,
		as you'd expect from in-game RNG.
	]]--

	local function getrandomcolor(index)
		local color
		
		local seed = ((memory.readword(rng) * ((extralevels * 4) + index)) % 4294967296)
		math.randomseed(seed)
		
		for i = seed % 8, 0, -1 do
			math.random()
		end

		if hasusedblack == true then
			color = colorsnoblack[math.random(#colorsnoblack)]
		else
			color = colors[math.random(#colors)]
		end
		
		if color == 13 and index > 0 then
			hasusedblack = true
		end

		return color
	end


	--[[
		Patching the ROM to fix the crashes that tend to occur at
		the very high levels due to score calculation.

		This is the same as using the Game Genie codes ASAPKG and TEEPSK.
	]]--

	rom.writebyte(7316, 80)
	rom.writebyte(7317, 14)


	--[[
		Main loop.
	]]--

	if emu.emulating() == true then
		romhash = rom.gethash("md5")
	else
		romhash = ""
	end

	if (romhash == "5b0e571558c8c796937b96af469561c6") or (romhash == "ec58574d96bee8c8927884ae6e7a2508") then
		print("~-----------------~ Classic Tetris: Infinite Levels ~-----------------~")
		print("~----~ An FCEUX script by momotsuki vol'gureschnxyzxyz ~----~")
		while (true) do
			if memory.readword(isingame) == 34311 and memory.readbyte(isbtype) == 0 then
				local currentlevel = memory.readbyte(leveladdr)

				if level0completed == false then
					if memory.readbyte(startinglevel) == 0 then
						if (currentlevel > 0) then
							level0completed = true
						end
					else
						level0completed = true
					end
				else
					if timer > 0 then
						timer = timer - 1
					end
				end
				
				if timer == 0 then
					if currentlevel == 0 then
						memory.writebyte(leveladdr, 255)
						memory.writebyte(levelmirroraddr, 255)
						extralevels = extralevels + 1
						hassetlevel = true
					elseif (hassetlevel) then
						local randomcolor0 = getrandomcolor(0)
						local randomcolor1 = getrandomcolor(1)
						local randomcolor2 = getrandomcolor(2)
						local randomcolor3 = getrandomcolor(3)

						writeppu(color0a, randomcolor0)
						writeppu(color0b, randomcolor0)			
						writeppu(color1a, randomcolor1)
						writeppu(color1b, randomcolor1)
						writeppu(color2a, randomcolor2)
						writeppu(color2b, randomcolor2)
						writeppu(color3a, randomcolor3)
						writeppu(color3b, randomcolor3)

						hassetlevel = false
						hasusedblack = false
					end
				end

				--[[
					The in-game level counter stops counting properly after 29, let alone 255.
					So let's replace it with our own.
				]]--
				
				local level = currentlevel + extralevels

				local levelcolor = ""
				
				if level > 255 then
					levelcolor = "#94008C"
				elseif level > 137 then
					levelcolor = "#E40060"
				elseif level > 28 then
					levelcolor = "#AC1000"
				elseif level > 18 then
					levelcolor = "#E46018"
				elseif level > 8 then
					levelcolor = "#AC9900"
				else
					levelcolor = "#FCF8FC"
				end
				
				gui.box(189, 157, 234, 178, "#000000", "#000000")
				gui.text(192, 160, "LEVEL", "#FCF8FC", "#000000")
				gui.text(192, 169, level, levelcolor, "#000000")
			else
				if level0completed == true then
					level0completed = false
					memory.writebyte(leveladdr, 0)
					memory.writebyte(levelmirroraddr, 0)
				end

				timer = 60
				extralevels = 0
			end

			emu.frameadvance()
		end
	else
		print("An unmodified Tetris ROM doesn't seem to be loaded! Please use one, and make sure it's loaded before you start this script.")
	end
end