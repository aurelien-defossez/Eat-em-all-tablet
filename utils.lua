-----------------------------------------------------------------------------------------
--
-- utils.lua
--
-----------------------------------------------------------------------------------------

local Arrow = require("Arrow")
local sprite = require("sprite")
local sprite = require("sprite")
local spritesheetData = require("spritesheetData")

-----------------------------------------------------------------------------------------
-- Attributes
-----------------------------------------------------------------------------------------

local spriteSheet = sprite.newSpriteSheetFromData("spritesheet.png", spritesheetData.getSpriteSheetData())
local spriteSheetIndex = {}

-----------------------------------------------------------------------------------------
-- Sprite initialization
-----------------------------------------------------------------------------------------

-- Initalize the index array to simply get an array index from its name
for key, value in pairs(spritesheetData.getSpriteSheetData().frames) do
	spriteSheetIndex[value.name] = key
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return a sprite index from its name
--
-- Parameters:
--  name: The sprite name
--
-- Returns:
--  index: The sprite index in the sprite sheet
function getSpriteIndexByName(name)
	return spriteSheetIndex[name]
end

-- Return the sprite set for the given sprites
--
-- Parameters:
--  sprites: A list of sprite names, with the number of frames for each one
--
-- Returns:
--  The sprite set containing all these animations
function loadSpriteSet(sprites)
	local spriteSet = sprite.newSpriteSet(spriteSheet, 1, 1)

	for spriteName, nbFrames in pairs(sprites) do
		local firstSpriteName = spriteName

		-- Rename sprite as the first sprite of the animation if it is one
		if nbFrames > 1 then
			firstSpriteName = firstSpriteName .. "_1"
		end
	
		-- Add the animation to the sprite set
		sprite.add(spriteSet, spriteName, getSpriteIndexByName(firstSpriteName .. ".png"), nbFrames, 600000)
	end
	
	return spriteSet
end

-- Return the reverse direction of the one given
--
-- Parameters:
--  direction: The direction as an Arrow constant
--
-- Returns:
--  The reverse direction, as an Arrow constant
function getReverseDirection(direction)
	if direction == Arrow.UP then
		return Arrow.DOWN
	elseif direction == Arrow.DOWN then
		return Arrow.UP
	elseif direction == Arrow.LEFT then
		return Arrow.RIGHT
	elseif direction == Arrow.RIGHT then
		return Arrow.LEFT
	end
end
