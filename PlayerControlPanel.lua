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

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.width = config.panels.controls.width

	-- Create sub-panels
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

	-- Draw background
	local background = display.newRect(self.x, self.y, self.width, self.height)
	background.strokeWidth = 3
	background:setFillColor(204, 109, 0)
	background:setStrokeColor(135, 72, 0)
	
	-- Add background to group
	self.group:insert(background)

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

-----------------------------------------------------------------------------------------

return PlayerControlPanel
