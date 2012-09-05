-----------------------------------------------------------------------------------------
--
-- CityShortcut.lua
--
-----------------------------------------------------------------------------------------

module("CityShortcut", package.seeall)

CityShortcut.__index = CityShortcut

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.CITY)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the city shortcut
--
-- Parameters:
--  city: The city this shortcut is linking to
--  player: The player this city is controlled by
--  x: X position
--  y: Y position
function CityShortcut.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, CityShortcut)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.x = self.city.x
	self.y = self.city.y
	self.width = config.city.width
	self.height = config.city.height

	-- Add to groups
	self.cityGroup = display.newGroup()
	
	self.group:insert(self.cityGroup)

	-- Register shortcut to city
	self.city.shortcut = self

	-- Draw sprite
	self.citySprite = SpriteManager.newSprite(spriteSet)
	self.citySprite:prepare("city" .. self.city.size .. "_" .. self.player.color.name)
	self.citySprite:play()

	-- Position sprite
	self.citySprite:setReferencePoint(display.CenterReferencePoint)
	self.citySprite.x = self.city.tile.width / 2
	self.citySprite.y = self.city.tile.height / 2

	-- Handle events
	self.citySprite:addEventListener("touch", self)

	-- Add to group
	self.cityGroup:insert(self.citySprite)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y
	
	return self
end

-- Destroy the shortcut, by notifying its linked city and removing every sprite
function CityShortcut:destroy()
	self.city.shortcut = nil
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Move the shortcut to an absolute position on the screen, easing it
function CityShortcut:transitionTo(parameters)
	transition.to(self.group, {
		transition = easing.outExpo,
		time = config.city.easingTime,
		x = parameters.x,
		y = parameters.y
	})

	self.x = parameters.x
	self.y = parameters.y
end

-- Update the number of inhabitants from the linked city
function CityShortcut:updateInhabitants()
	-- self.inhabitantsText.text = self.city.inhabitants
end

-- Check if a pixel is in the city shortcut
--
-- Parameters:
--  x: The X position
--  y: The Y position
--
-- Returns:
--  True if the pixel is inside the shortcut coordinates
function CityShortcut:isInside(parameters)
	return (parameters.x >= self.x and parameters.x < self.x + self.width
		and parameters.y >= self.y and parameters.y < self.y + self.height)
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Touch handler on a city
--
-- Parameters:
--  event: The touch event
function CityShortcut:touch(event)
	-- Open the gates while the finger touches the city
	self.city.gateOpened = self:isInside(event)
		and event.phase ~= "ended" and event.phase ~= "cancelled"

	-- Focus this object in order to track this finger properly
	display.getCurrentStage():setFocus(event.target, event.id)

	return true
end

-----------------------------------------------------------------------------------------

return CityShortcut
