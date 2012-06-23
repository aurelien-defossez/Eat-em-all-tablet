-----------------------------------------------------------------------------------------
--
-- Grid.lua
--
-----------------------------------------------------------------------------------------

module("Grid", package.seeall)

Grid.__index = Grid

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local ArrowsPanel = require("ArrowsPanel")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Grid.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Grid)
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Grid:draw()
	-- Boundaries
	local xEnd = self.x + self.width
	local yEnd = self.y + self.height

	-- Draw grid (Rows)
	local yStep = self.height / config.panels.grid.nbRows
	for y = self.y, yEnd + 1, yStep do
		local yFloored = math.floor(y)
		local line = display.newLine(self.x, yFloored, xEnd, yFloored)
		line.width = config.panels.grid.lineWidth
		line:setColor(60, 30, 0)
	end
	
	-- Draw grid (Columns)
	local xStep = self.width / config.panels.grid.nbCols
	for x = self.x, xEnd + 1, xStep do
		local xFloored = math.floor(x)
		local line = display.newLine(xFloored, self.y, xFloored, yEnd)
		line.width = config.panels.grid.lineWidth
		line:setColor(60, 30, 0)
	end
end

-----------------------------------------------------------------------------------------

return Grid
