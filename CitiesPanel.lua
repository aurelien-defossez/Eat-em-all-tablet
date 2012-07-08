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
--  city: The city controlled
function CitiesPanel:gainCity(city)
	local shortcut = CityShortcut.create{
		city = city,
		player = self.player
	}

	shortcut:draw()

	self.shortcuts[city.id] = shortcut

	self:reorganize()
end

-- Lose the control of a city
--
-- Parameters:
--  city: The city lost
function CitiesPanel:loseCity(city)
	self.shortcuts[city.id]:destroy()
	self.shortcuts[city.id] = nil

	self:reorganize()
end

-- Reorganize shortcuts by sorting them alphabetically and moving them accordingly
function CitiesPanel:reorganize()
	local i = 0
	local j = 0
	local orderedShortcuts = {}
	
	-- Sort shortcuts by id
	for index, shortcut in pairs(self.shortcuts) do
		table.insert(orderedShortcuts, shortcut)
	end

	table.sort(orderedShortcuts, compareLess)

	-- Move shortcuts to their new place
	for index, shortcut in ipairs(orderedShortcuts) do
		shortcut:moveTo{
			x = self.x + i * config.city.width,
			y = self.y + j * config.city.height
		}

		j = j + 1

		if j == config.panels.controls.cities.nbRows then
			i = i + 1
			j = 0
		end
	end
end

-- Comparison function for sorting chortcuts
function compareLess(a, b)
	return a.city.id < b.city.id
end

-----------------------------------------------------------------------------------------

return CitiesPanel
