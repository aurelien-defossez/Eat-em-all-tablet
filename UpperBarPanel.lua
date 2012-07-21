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
local GameScene = require("GameScene")
local HitPointsPanel = require("HitPointsPanel")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()

	HitPointsPanel.initialize()
end

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
	self.hpWidth = (config.screen.width - config.panels.upperBar.menuButton.width) / 2

	self.hitPoints = {}
	self.hitPoints[1] = HitPointsPanel.create{
		maxHitPoints = self.players[1].hitPoints,
		hitPoints = self.players[1].hitPoints,
		x = 0,
		y = 0,
		width = self.hpWidth,
		direction = HitPointsPanel.FORWARD
	}

	self.hitPoints[2] = HitPointsPanel.create{
		maxHitPoints = self.players[2].hitPoints,
		hitPoints = self.players[2].hitPoints,
		x = self.hpWidth + config.panels.upperBar.menuButton.width,
		y = 0,
		width = self.hpWidth,
		direction = HitPointsPanel.REVERSE
	}

	self.players[1].hitPointsPanel = self.hitPoints[1]
	self.players[2].hitPointsPanel = self.hitPoints[2]
	
	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y
	
	return self
end

-- Destroy the panel
function UpperBarPanel:destroy()
	self.hitPoints[1]:destroy()
	self.hitPoints[2]:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the upper bar panel
function UpperBarPanel:draw()
	-- Draw HP bars
	for index, panel in pairs(self.hitPoints) do
		panel:draw()
	end

	-- Draw pause button
	self.pauseSprite = display.newImageRect("pause.png",
		config.panels.upperBar.menuButton.pause.width, config.panels.upperBar.menuButton.pause.height)

	-- Position sprite
	self.pauseSprite:setReferencePoint(display.CenterReferencePoint)
	self.pauseSprite.x = self.hpWidth + config.panels.upperBar.menuButton.width / 2
	self.pauseSprite.y = config.panels.upperBar.height / 2

	-- Add listener on pause tap
	self.pauseSprite:addEventListener("tap", onPauseTap)

	-- Add to group
	self.group:insert(self.pauseSprite)
end

-----------------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------------

-- Tap handler on the pause button
function onPauseTap(event)
	GameScene.switchPause()
end

-----------------------------------------------------------------------------------------

return UpperBarPanel
