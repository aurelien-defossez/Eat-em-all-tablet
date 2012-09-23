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
require("src.sprites.Sprites")

local Sprite = require("sprite")
local SpritesheetData = require("src.sprites.SpritesheetData")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

spriteSheet = nil
spriteSets = nil
spriteSheetIndex = nil
timeScale = 1

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
	spriteSets[SPRITE_SET.MANA] = loadSpriteSet(sprites.mana)
	spriteSets[SPRITE_SET.ZOMBIE] = loadSpriteSet(sprites.zombie)
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
	local sprite = Sprite.newSprite(spriteSet)
	sprite.timeScale = timeScale

	return sprite
end

-- Sets the animation time scale.
-- A time scale of 1.0 runs the animation at normal speed.
-- A time scale of 2.0 runs the animation twice as fast.
-- A time scale of 0.5 runs the animation at half speed.
--
-- Parameters:
--  newTimeScale: The time scale
function setTimeScale(newTimeScale)
	timeScale = newTimeScale

	Runtime:dispatchEvent{
		name = "spriteChangeSpeed",
		timeScale = newTimeScale
	}
end

-----------------------------------------------------------------------------------------

return SpriteManager
