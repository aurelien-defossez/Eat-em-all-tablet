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
	
	return self
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
end

function HitPointsPanel:updateHPs(hitPoints)
	self.hitPoints = hitPoints

	local greenWidth = math.ceil(self.barPosition.maxWidth * self.hitPoints / self.maxHitPoints)
	local redWidth = self.barPosition.maxWidth - greenWidth

	self.greenBar.width = greenWidth
	self.greenBar.x = self.barPosition.x + greenWidth / 2
	self.redBar.width = redWidth
	self.redBar.x = self.barPosition.x + greenWidth + redWidth / 2
end

-----------------------------------------------------------------------------------------

return HitPointsPanel
