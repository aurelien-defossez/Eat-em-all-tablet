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
require("src.config.GameConfig")

local Sprite = require("sprite")

local SpritesheetData = require("src.utils.SpritesheetData")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

ARROW = 1
CEMETERY = 2
CITY = 3
FORTRESS_WALL = 4
ITEM = 5
ZOMBIE = 6
MISC = 42

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

spriteSheet = nil
spriteSets = nil
spriteSheetIndex = nil

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Initializes the sprite manager
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
	spriteSets[ARROW] = loadSpriteSet(config.sprites.arrow)
	spriteSets[CEMETERY] = loadSpriteSet(config.sprites.cemetery)
	spriteSets[CITY] = loadSpriteSet(config.sprites.city)
	spriteSets[FORTRESS_WALL] = loadSpriteSet(config.sprites.fortressWall)
	spriteSets[ITEM] = loadSpriteSet(config.sprites.item)
	spriteSets[ZOMBIE] = loadSpriteSet(config.sprites.zombie)
	spriteSets[MISC] = loadSpriteSet(config.sprites.misc)
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

		-- Rename sprite as the first sprite of the animation if it is one
		if frameCount == 1 then
			firstSpriteName = spriteName
		else
			firstSpriteName = spriteName .. "_1"
		end
	
		-- Add the animation to the sprite set
		Sprite.add(spriteSet, spriteName, spriteSheetIndex[firstSpriteName .. ".png"], frameCount, period)
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
