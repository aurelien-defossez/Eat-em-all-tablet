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
local Tile = require("Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

PIXEL = 1
TILE = 2

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Grid.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Grid)

	-- Initialize attributes
	self.matrix = {}
	for x = 1, config.panels.grid.nbRows do
		for y = 1, config.panels.grid.nbCols do
			self.matrix[getIndex(x, y)] = Tile.create{
				x = x,
				y = y
			}
		end
	end
	
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

function Grid:getTile(parameters)
	if parameters.unit == PIXEL then
		return self:getTile{
			x = math.floor((parameters.x - self.x) / self.width * config.panels.grid.nbCols) + 1,
			y = math.floor((parameters.y - self.y) / self.height * config.panels.grid.nbRows) + 1,
			unit = TILE
		}
	else
		return self.matrix[getIndex(parameters.x, parameters.y)]
	end
end

function Grid:placeArrow(parameters)
	if parameters.tile.content == nil then
		print("NIL")
		parameters.tile.content = parameters.player.id
	else
		print("to player " .. parameters.tile.content)
	end
end

-----------------------------------------------------------------------------------------
-- Local methods
-----------------------------------------------------------------------------------------

function Grid.getIndex(x, y)
	return x * config.panels.grid.nbCols + y
end

-----------------------------------------------------------------------------------------

return Grid
