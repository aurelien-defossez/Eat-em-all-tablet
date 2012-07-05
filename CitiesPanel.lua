-----------------------------------------------------------------------------------------
--
-- CitiesPanel.lua
--
-----------------------------------------------------------------------------------------

module("CitiesPanel", package.seeall)

CitiesPanel.__index = CitiesPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local CityShortcut = require("CityShortcut")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the cities panel
--
-- Parameters:
--  player: The cities panel owner
--  x: X position
--  y: Y position
function CitiesPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, CitiesPanel)
	
	-- Initialize attributes
	self.width = config.panels.controls.cities.width
	self.height = config.screen.height - self.y - config.panels.controls.cities.ypadding
	self.shortcuts = {}

	-- Register itself to the player
	self.player.citiesPanel = self
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the cities panel
function CitiesPanel:draw()
	-- Nothing to draw
end

-- Add a city under the control of the player
--
-- Parameters:
--  The city controlled
function CitiesPanel:gainCity(city)
	local shortcut = CityShortcut.create{
		city = city,
		player = self.player
	}

	shortcut:draw()

	shortcut:moveTo{
		x = self.x,
		y = self.y
	}

	self.shortcuts[city.id] = shortcut
end

-- Lose the control of a city
--
-- Parameters:
--  The city lost
function CitiesPanel:loseCity(city)
	self.shortcuts[city.id]:destroy()
	self.shortcuts[city.id] = nil
end

-----------------------------------------------------------------------------------------

return CitiesPanel
