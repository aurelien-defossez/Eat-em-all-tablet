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
	self.proxies = {}

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

-- Play the given animation
--
-- Parameters:
--  animationName: The animation to play
function Sprite:play(animationName)
	self.sprite:prepare(animationName)
	self.sprite:play()
end

-- Pause the sprite animation
function Sprite:pause()
	self.isAnimating = self.sprite.animating
	self.sprite:pause()
end

-- Resume the sprite animation
function Sprite:resume()
	if self.isAnimating then
		self.sprite:play()
	end
end

-- Move the sprite
--
-- Parameters:
--  x: The x position
--  y: The y position
function Sprite:move(parameters)
	self.x = parameters.x
	self.y = parameters.y
	self.sprite.x = self.x
	self.sprite.y = self.y
end

-- Add an event listener
--
-- Parameters:
--  eventName: The event name
--  listener: The listener
function Sprite:addEventListener(eventName, listener)
	if self.proxies[eventName] then
		print("===========================================================")
		print("ERROR: Listener already attached for "..eventName)
		print("===========================================================")
	else
		-- Create proxy listener
		-- A proxy is created in order to set the event.target point to the custom Sprite object (self) and not
		-- the Corona Sprite object (self.sprite)
		local proxy = ProxyListener.create{
			listener = listener,
			target = self
		}

		-- Save proxy and attach the real listener to the proxy
		-- The proxy will receive the sprite events and will directly call the real listener
		self.proxies[eventName] = proxy
		self.sprite:addEventListener(eventName, proxy)
	end
end

-- Remove the event listener
--
-- Parameters:
--  eventName: The event name
--  listener: The listener
function Sprite:removeEventListener(eventName, listener)
	self.sprite:removeEventListener(eventName, self.proxies[eventName])
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
		self:pause()
	else
		self:resume()
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
