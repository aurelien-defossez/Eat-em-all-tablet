-----------------------------------------------------------------------------------------
--
-- Sprite.lua
--
-----------------------------------------------------------------------------------------

module("Sprite", package.seeall)

Sprite.__index = Sprite

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local SpriteManager = require("src.sprites.SpriteManager")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the sprite
--
-- Parameters:
--  spriteSet: The spriteSet (from the sprite manager)
--  group: The display group to add the sprite to
--  referencePoint: The reference point (default is display.CenterReferencePoint)
--  x: The x position (default is 0)
--  y: The y position (default is 0)
function Sprite.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Sprite)

	-- Initialize attributes
	self.referencePoint = self.referencePoint or display.CenterReferencePoint
	self.x = self.x or 0
	self.y = self.y or 0

	-- Create Corona sprite
	self.sprite = SpriteManager.newSprite(self.spriteSet)

	-- Set reference point
	self.sprite:setReferencePoint(self.referencePoint)

	-- Position sprite
	self.sprite.x = self.x
	self.sprite.y = self.y

	-- Add sprite to group
	self.group:insert(self.sprite)

	-- Listen to events
	Runtime:addEventListener("spritePause", self)
	Runtime:addEventListener("spriteChangeSpeed", self)

	return self
end

-- Destroy the sprite
function Sprite:destroy()
	Runtime:removeEventListener("spritePause", self)
	Runtime:removeEventListener("spriteChangeSpeed", self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Sprite:play(animationName)
	if animationName then
		self.sprite:prepare(animationName)
	end

	self.sprite:play()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function Sprite:spritePause(event)
	if event.status then
		self.sprite:pause()
	else
		self.sprite:play()
	end
end

-- Change the sprite animation speed
-- Parameters:
--  event: The event, with these values:
--   timeScale: The new time scale
function Sprite:spriteChangeSpeed(event)
	self.sprite.timeScale = event.timeScale
end

-----------------------------------------------------------------------------------------

return Sprite
