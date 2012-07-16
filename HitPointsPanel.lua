-----------------------------------------------------------------------------------------
--
-- HitPointsPanel.lua
--
-----------------------------------------------------------------------------------------

module("HitPointsPanel", package.seeall)

HitPointsPanel.__index = HitPointsPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

FORWARD = 1
REVERSE = 2

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the hit points panel
--
-- Parameters:
--  maxHitPoints: The maximal number of hitPoints
--  hitPoints: The current number of hitPoints
--  x: X position
--  y: Y position
--  width: The width
function HitPointsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, HitPointsPanel)
	
	-- Initialize attributes
	self.height = config.panels.upperBar.height
	self.barPosition = {
		x = self.x + config.panels.upperBar.hitPoints.xpadding,
		y = self.y + config.panels.upperBar.hitPoints.ypadding,
		maxWidth = self.width - 2 * config.panels.upperBar.hitPoints.xpadding,
		height = self.height - 2 * config.panels.upperBar.hitPoints.ypadding
	}

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	return self
end

-- Destroy the panel
function HitPointsPanel:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the hit points panel
function HitPointsPanel:draw()
	self.greenBar = display.newRect(0, self.barPosition.y, 0, self.barPosition.height)
	self.greenBar.x = self.barPosition.x
	self.greenBar.strokeWidth = 2
	self.greenBar:setFillColor(30, 200, 30)

	self.redBar = display.newRect(0, self.barPosition.y, 0, self.barPosition.height)
	self.redBar.strokeWidth = 2
	self.redBar:setFillColor(200, 30, 30)

	self:updateHPs(self.hitPoints)

	self.group:insert(self.greenBar)
	self.group:insert(self.redBar)
end

function HitPointsPanel:updateHPs(hitPoints)
	self.hitPoints = hitPoints

	local greenWidth = math.ceil(self.barPosition.maxWidth * self.hitPoints / self.maxHitPoints)
	local redWidth = self.barPosition.maxWidth - greenWidth

	self.greenBar.width = greenWidth
	self.redBar.width = redWidth

	if self.direction == FORWARD then
		self.greenBar.x = self.barPosition.x + greenWidth / 2
		self.redBar.x = self.barPosition.x + greenWidth + redWidth / 2
	else
		self.greenBar.x = self.barPosition.x + redWidth + greenWidth / 2
		self.redBar.x = self.barPosition.x + redWidth / 2
	end
end

-----------------------------------------------------------------------------------------

return HitPointsPanel
