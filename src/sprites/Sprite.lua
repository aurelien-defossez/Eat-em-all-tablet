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
local ProxyListener = require("src.sprites.ProxyListener")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the sprite
--
-- Parameters:
--  spriteSet: The spriteSet got from the sprite manager
--  group: The display group to add the sprite to (optional)
--  referencePoint: The reference point (default is display.CenterReferencePoint)
--  x: The x position (default is 0)
--  y: The y position (default is 0)
--  orientation: The sprite orientation (default is 0)
--  scale: The uniform scale on both x and y axis (default is 1)
function Sprite.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Sprite)

	-- Initialize attributes
	self.referencePoint = self.referencePoint or display.CenterReferencePoint
	self.x = self.x or 0
	self.y = self.y or 0
	self.orientation = self.orientation or 0
	self.scale = self.scale or 1

	-- Create Corona sprite
	self.sprite = SpriteManager.newSprite(self.spriteSet)

	-- Set reference point
	self.sprite:setReferencePoint(self.referencePoint)

	-- Prepare sprite
	self.sprite.x = self.x
	self.sprite.y = self.y
	self.sprite:rotate(self.orientation)
	self.sprite.xScale = self.scale
	self.sprite.yScale = self.scale

	-- Add sprite to group
	if self.group then
		self.group:insert(self.sprite)
	end

	-- Listen to events
	Runtime:addEventListener("spritePause", self)
	Runtime:addEventListener("spriteChangeSpeed", self)

	return self
end

-- Destroy the sprite
function Sprite:destroy()
	Runtime:removeEventListener("spritePause", self)
	Runtime:removeEventListener("spriteChangeSpeed", self)
	self.sprite:removeSelf()
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

function Sprite:move(parameters)
	self.x = parameters.x
	self.y = parameters.y
	self.sprite.x = self.x
	self.sprite.y = self.y
end

function Sprite:addEventListener(eventName, listener)
	if self.proxy then
		print("===========================================================")
		print("ERROR: Cannot attach two event listeners on the same sprite")
		print("===========================================================")
		return
	end

	self.proxy = ProxyListener.create{
		listener = listener,
		target = self
	}

	self.sprite:addEventListener(eventName, self.proxy)
end

function Sprite:removeEventListener(eventName, listener)
	self.sprite:removeEventListener(eventName, self.proxy)
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
