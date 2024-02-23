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
]]--

require "InfiniteLevels"
InfiniteLevels()