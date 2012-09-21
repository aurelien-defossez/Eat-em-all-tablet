-----------------------------------------------------------------------------------------
--
-- SpriteManager.lua
--
-----------------------------------------------------------------------------------------

module("SpriteManager", package.seeall)

SpriteManager.__index = SpriteManager

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.Sprites")

local Sprite = require("sprite")

local SpritesheetData = require("src.utils.SpritesheetData")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

spriteSheet = nil
spriteSets = nil
spriteSheetIndex = nil

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Pre load sprites
function initialize()
	-- Load sprite sheet
	local spritesheetData = SpritesheetData.getSpriteSheetData()
	spriteSheet = Sprite.newSpriteSheetFromData("images/bin/spritesheet.png", spritesheetData)
	spriteSheetIndex = {}

	-- Initalize the index array to simply get an array index from its name
	for key, value in pairs(spritesheetData.frames) do
		spriteSheetIndex[value.name] = key
	end

	-- Load sprite sets
	spriteSets = {}
	spriteSets[SPRITE_SET.ARROW] = loadSpriteSet(sprites.arrow)
	spriteSets[SPRITE_SET.CEMETERY] = loadSpriteSet(sprites.cemetery)
	spriteSets[SPRITE_SET.CITY] = loadSpriteSet(sprites.city)
	spriteSets[SPRITE_SET.FORTRESS_WALL] = loadSpriteSet(sprites.fortressWall)
	spriteSets[SPRITE_SET.ITEM] = loadSpriteSet(sprites.item)
	spriteSets[SPRITE_SET.ZOMBIE] = loadSpriteSet(sprites.zombie)
	spriteSets[SPRITE_SET.TORNADO] = loadSpriteSet(sprites.tornado)
	spriteSets[SPRITE_SET.MINE] = loadSpriteSet(sprites.mine)
	spriteSets[SPRITE_SET.MISC] = loadSpriteSet(sprites.misc)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return the sprite set for the given sprites
--
-- Parameters:
--  sprites: A list of sprite names, with the number of frames for each one
--
-- Returns:
--  The sprite set containing all these animations
function loadSpriteSet(sprites)
	local spriteSet = Sprite.newSpriteSet(spriteSheet, 1, 1)

	for spriteName, animation in pairs(sprites) do
		local firstSpriteName
		local frameCount = animation.frameCount or 1
		-- Set the period to 10 minutes if no period is defined (= steady frame)
		local period = animation.period or 600000
		-- Set the loop parameter to 0 (loop indefinitely) by default or 1 (one loop) if loop is false
		local loop = (animation.loop == false) and 1 or 0

		-- Rename sprite as the first sprite of the animation if it is one
		if frameCount == 1 then
			firstSpriteName = spriteName
		else
			firstSpriteName = spriteName .. "_01"
		end
		
		-- Add the animation to the sprite set
		Sprite.add(spriteSet, spriteName, spriteSheetIndex[firstSpriteName .. ".png"], frameCount, period, loop)
	end
	
	return spriteSet
end

-- Return a sprite set by name
--
-- Parameters:
--  name: The sprite set name
--
-- Returns:
--  The sprite set
function getSpriteSet(name)
	return spriteSets[name]
end

-- Instanciate a sprite for a certain sprite set
--
-- Parameters:
--  spriteSet: The sprite set
--
-- Returns:
--  A new instance of the sprite set
function newSprite(spriteSet)
	return Sprite.newSprite(spriteSet)
end

-----------------------------------------------------------------------------------------

return SpriteManager
