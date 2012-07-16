-----------------------------------------------------------------------------------------
--
-- PlayerControlPanel.lua
--
-----------------------------------------------------------------------------------------

module("PlayerControlPanel", package.seeall)

PlayerControlPanel.__index = PlayerControlPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local ItemsPanel = require("ItemsPanel")
local ArrowsPanel = require("ArrowsPanel")
local CitiesPanel = require("CitiesPanel")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the player control panel
--
-- Parameters:
--  player: The control panel owner
--  x: X position
--  y: Y position
--  height: Height (Width is hardcoded in configuration file)
--  grid: The grid
function PlayerControlPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PlayerControlPanel)
	
	-- Initialize attributes
	self.width = config.panels.controls.width

	self.items = ItemsPanel.create{
		player = self.player,
		grid = self.grid,
		x = self.x + config.panels.controls.padding,
		y = self.y + config.panels.controls.items.ypadding
	}

	self.arrows = ArrowsPanel.create{
		player = self.player,
		grid = self.grid,
		x = self.x + config.panels.controls.padding,
		y = self.y + self.height / 2 - config.panels.controls.arrows.height / 2
	}
	
	self.cities = CitiesPanel.create{
		player = self.player,
		x = self.x + config.panels.controls.padding,
		y = self.y + self.height / 2 + config.panels.controls.arrows.height / 2 + config.panels.controls.cities.ypadding
	}

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	return self
end

-- Destroy the panel
function PlayerControlPanel:destroy()
	self.cities:destroy()
	self.arrows:destroy()
	self.items:destroy()

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the control panel
function PlayerControlPanel:draw()
	local background = display.newRect(self.x, self.y, self.width, self.height)
	background.strokeWidth = 3
	background:setFillColor(204, 109, 0)
	background:setStrokeColor(135, 72, 0)
	
	self.items:draw()
	self.arrows:draw()
	self.cities:draw()

	-- Add background to group
	self.group:insert(background)
end

-----------------------------------------------------------------------------------------

return PlayerControlPanel
