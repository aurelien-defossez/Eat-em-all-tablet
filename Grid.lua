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

local ArrowsPanel = require("ArrowsPanel")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

NB_ROWS = 10
NB_COLS = 11
PADDING = 6
LINE_WIDTH = 2

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Grid.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Grid)
	
	-- Initialize attributes
	self.nbRows = NB_ROWS
	self.nbCols = NB_COLS
	
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
	local yStep = self.height / self.nbRows
	for y = self.y, yEnd + 1, yStep do
		local yFloored = math.floor(y)
		local line = display.newLine(self.x, yFloored, xEnd, yFloored)
		line.width = LINE_WIDTH
		line:setColor(60, 30, 0)
	end
	
	-- Draw grid (Columns)
	local xStep = self.width / NB_COLS
	for x = self.x, xEnd + 1, xStep do
		local xFloored = math.floor(x)
		local line = display.newLine(xFloored, self.y, xFloored, yEnd)
		line.width = LINE_WIDTH
		line:setColor(60, 30, 0)
	end
end

-----------------------------------------------------------------------------------------

return Grid
