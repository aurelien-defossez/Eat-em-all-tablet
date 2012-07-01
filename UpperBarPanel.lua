-----------------------------------------------------------------------------------------
--
-- UpperBarPanel.lua
--
-----------------------------------------------------------------------------------------

module("UpperBarPanel", package.seeall)

UpperBarPanel.__index = UpperBarPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local HitPointsPanel = require("HitPointsPanel")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the upper bar panel
--
-- Parameters:
--  players: The two players
function UpperBarPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, UpperBarPanel)
	
	-- Initialize attributes
	self.height = config.panels.upperBar.height

	local hpWidth = (config.screen.width - config.panels.upperBar.menuButton.width) / 2

	self.hitPoints = {}
	self.hitPoints[1] = HitPointsPanel.create{
		maxHitPoints = self.players[1].hitPoints,
		hitPoints = self.players[1].hitPoints,
		x = 0,
		y = 0,
		width = hpWidth,
		direction = HitPointsPanel.FORWARD
	}

	self.hitPoints[2] = HitPointsPanel.create{
		maxHitPoints = self.players[2].hitPoints,
		hitPoints = self.players[2].hitPoints,
		x = hpWidth + config.panels.upperBar.menuButton.width,
		y = 0,
		width = hpWidth,
		direction = HitPointsPanel.REVERSE
	}

	self.players[1].hitPointsPanel = self.hitPoints[1]
	self.players[2].hitPointsPanel = self.hitPoints[2]
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the upper bar panel
function UpperBarPanel:draw()
	for index, panel in pairs(self.hitPoints) do
		panel:draw()
	end
end

-----------------------------------------------------------------------------------------

return UpperBarPanel
