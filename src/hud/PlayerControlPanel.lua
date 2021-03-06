-----------------------------------------------------------------------------------------
--
-- PlayerControlPanel.lua
--
-- The player control panel, which contains the upgrade panel, the arrows panel and the
-- powers panel.
--
-----------------------------------------------------------------------------------------

module("PlayerControlPanel", package.seeall)
PlayerControlPanel.__index = PlayerControlPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local UpgradePanel = require("src.hud.UpgradePanel")
local ArrowsPanel = require("src.hud.ArrowsPanel")
local PowersPanel = require("src.hud.PowersPanel")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

-- Initialize the class
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
	self.width = hud.controls.width

	-- Create sub-panels
	self.upgrade = UpgradePanel.create{
		player = self.player,
		x = self.x + hud.controls.padding,
		y = self.y
	}

	self.arrows = ArrowsPanel.create{
		player = self.player,
		grid = self.grid,
		x = self.x + hud.controls.padding,
		y = self.y + hud.controls.upgrade.height + hud.controls.powers.ypadding
	}

	self.powers = PowersPanel.create{
		player = self.player,
		grid = self.grid,
		x = self.x + hud.controls.padding,
		y = self.y + hud.controls.upgrade.height + hud.controls.arrows.height
			+ hud.controls.powers.ypadding
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
	self.upgrade:destroy()
	self.arrows:destroy()
	self.powers:destroy()

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------

return PlayerControlPanel
