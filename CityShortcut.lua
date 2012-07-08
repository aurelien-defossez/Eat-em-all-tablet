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

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
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
	
	-- Initialize attributes
	self.x = self.city.x
	self.y = self.city.y
	self.width = config.city.width
	self.height = config.city.height

	-- Manage groups
	self.cityGroup = display.newGroup()
	self.textGroup = display.newGroup()
	self.group = display.newGroup()
	
	self.group:insert(self.cityGroup)
	self.group:insert(self.textGroup)
	classGroup:insert(self.group)

	-- Register shortcut to city
	self.city.shortcut = self
	
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

-- Draw the city
function CityShortcut:draw()
	-- Draw city
	self:drawSprite()

	-- Inhabitants count text
	self.inhabitantsText = display.newText(self.city.inhabitants, config.city.inhabitantsText.x,
		config.city.inhabitantsText.y, native.systemFontBold, 16)
	self.inhabitantsText:setTextColor(0, 0, 0)

	-- Name text
	self.nameText = display.newText(self.city.name, config.city.nameText.x, config.city.nameText.y,
		native.systemFontBold, 16)
	self.nameText:setTextColor(0, 0, 0)

	-- Add texts to group
	self.textGroup:insert(self.inhabitantsText)
	self.textGroup:insert(self.nameText)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y
end

-- Move the shortcut to an absolute position on the screen, easing it
function CityShortcut:moveTo(parameters)
	transition.to(self.group, {
		transition = easing.outExpo,
		time = config.city.easingTime,
		x = parameters.x,
		y = parameters.y
	})

	self.x = parameters.x
	self.y = parameters.y
end

-- Draw the city sprite
function CityShortcut:drawSprite()
	local spriteName = "city" .. self.city.size .. "_" .. self.player.color .. ".png"
	
	-- Create sprite
	self.sprite = display.newImageRect(spriteName, config.city.width, config.city.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.city.tile.width / 2
	self.sprite.y = self.city.tile.height / 2
	
	-- Handle events
	self.sprite.cityShortcut = self
	self.sprite:addEventListener("touch", onCityTouch)

	-- Insert into group
	self.cityGroup:insert(self.sprite)
end

-- Update the number of inhabitants from the linked city
function CityShortcut:updateInhabitants()
	self.inhabitantsText.text = self.city.inhabitants
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
-- Private Methods
-----------------------------------------------------------------------------------------

-- Touch handler on a city
function onCityTouch(event)
	local cityShortcut = event.target.cityShortcut

	-- Open the gates while the finger touches the city
	cityShortcut.city.gateOpened = cityShortcut:isInside(event)
		and event.phase ~= "ended" and event.phase ~= "cancelled"

	-- Focus this object in order to track this finger properly
	display.getCurrentStage():setFocus(event.target, event.id)
end

-----------------------------------------------------------------------------------------

return CityShortcut
