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

require("src.utils.Constants")
require("src.config.GameConfig")

local CityShortcut = require("src.hud.CityShortcut")
local TableLayout = require("src.utils.TableLayout")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

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

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
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

	self.tableLayout:addItem(shortcut)
end

-- Lose the control of a city
--
-- Parameters:
--  city: The city lost
function CitiesPanel:loseCity(city)
	self.tableLayout:removeItem(city.id)
end

-----------------------------------------------------------------------------------------

return CitiesPanel
