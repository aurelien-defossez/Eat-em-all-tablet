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
local TableLayout = require("TableLayout")

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
	self.tableLayout = TableLayout.create{
		x = self.x,
		y = self.y,
		width = self.width,
		height = self.height,
		itemWidth = config.city.width,
		itemHeight = config.city.height,
		direction = self.player.tableLayoutDirection
	}

	-- Register itself to the player
	self.player.citiesPanel = self
	
	return self
end

-- Destroy the panel
function CitiesPanel:destroy()
	self.tableLayout:destroy()

	self.group:removeSelf()
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
--  city: The city controlled
function CitiesPanel:gainCity(city)
	local shortcut = CityShortcut.create{
		id = city.id,
		city = city,
		player = self.player
	}

	shortcut:draw()
	self.tableLayout:addItem(shortcut)
end

-- Lose the control of a city
--
-- Parameters:
--  city: The city lost
function CitiesPanel:loseCity(city)
	self.tableLayout:removeItem(city)
end

-----------------------------------------------------------------------------------------

return CitiesPanel
