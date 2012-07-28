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

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local HitPointsPanel = require("src.hud.HitPointsPanel")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.MISC)

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
	
	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
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
		direction = HIT_POINTS_PANEL.DIRECTION.FORWARD
	}

	self.hitPoints[2] = HitPointsPanel.create{
		maxHitPoints = self.players[2].hitPoints,
		hitPoints = self.players[2].hitPoints,
		x = self.hpWidth + config.panels.upperBar.menuButton.width,
		y = 0,
		width = self.hpWidth,
		direction = HIT_POINTS_PANEL.DIRECTION.REVERSE
	}

	self.players[1].hitPointsPanel = self.hitPoints[1]
	self.players[2].hitPointsPanel = self.hitPoints[2]

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw pause button
	self.pauseSprite = SpriteManager.newSprite(spriteSet)
	self.pauseSprite:prepare("pause")
	self.pauseSprite:play()

	-- Position sprite
	self.pauseSprite:setReferencePoint(display.CenterReferencePoint)
	self.pauseSprite.x = self.hpWidth + config.panels.upperBar.menuButton.width / 2
	self.pauseSprite.y = config.panels.upperBar.height / 2

	-- Add listener on pause tap
	self.pauseSprite:addEventListener("tap", onPauseTap)

	-- Add to group
	self.group:insert(self.pauseSprite)
	
	return self
end

-- Destroy the panel
function UpperBarPanel:destroy()
	self.hitPoints[1]:destroy()
	self.hitPoints[2]:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Tap handler on the pause button
function onPauseTap(event)
	Runtime:dispatchEvent{
		name = "gamePause",
		system = false,
		switch = true
	}
end

-----------------------------------------------------------------------------------------

return UpperBarPanel
