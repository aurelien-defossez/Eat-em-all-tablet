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

local config = require("GameConfig")
local spriteApi = require("sprite")
local spritesheetData = require("spritesheetData")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

SET = {
	CITY = 1
}

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
	local data = spritesheetData.getSpriteSheetData()
	spriteSheet = spriteApi.newSpriteSheetFromData("spritesheet.png", data)
	spriteSheetIndex = {}

	-- Initalize the index array to simply get an array index from its name
	for key, value in pairs(data.frames) do
		spriteSheetIndex[value.name] = key
	end

	-- Load sprite sets
	spriteSets = {}
	spriteSets[SET.CITY] = loadSpriteSet(config.sprites.city)
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
	local spriteSet = spriteApi.newSpriteSet(spriteSheet, 1, 1)

	for spriteName, animation in pairs(sprites) do
		local firstSpriteName
		local frameCount = animation.frameCount or 1
		local period = animation.period or 600000

		-- Rename sprite as the first sprite of the animation if it is one
		if frameCount == 1 then
			firstSpriteName = spriteName
		else
			firstSpriteName = spriteName .. "_1"
		end
	
		-- Add the animation to the sprite set
		spriteApi.add(spriteSet, spriteName, spriteSheetIndex[firstSpriteName .. ".png"], frameCount, period)
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
	return spriteApi.newSprite(spriteSet)
end

-----------------------------------------------------------------------------------------

return SpriteManager
