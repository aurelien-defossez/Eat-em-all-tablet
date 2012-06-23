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

	local saveWidth = self.width
	local saveHeight = self.height

	-- Initialize attributes
	self.tileWidth = math.floor(self.width / config.panels.grid.nbCols)
	self.tileHeight = math.floor(self.height / config.panels.grid.nbRows)
	self.width = self.tileWidth * config.panels.grid.nbCols
	self.height = self.tileHeight * config.panels.grid.nbRows

	self.x = self.x + math.floor((saveWidth - self.width) / 2)
	self.y = self.y + math.floor((saveHeight - self.height) / 2)

	self.matrix = {}
	for x = 1, config.panels.grid.nbRows + 1 do
		for y = 1, config.panels.grid.nbCols + 1 do
			self.matrix[getIndex(x, y)] = Tile.create{
				xGrid = x,
				yGrid = y,
				x = self.x + (x - 1) * self.tileWidth,
				y = self.y + (y - 1) * self.tileHeight,
				width = self.tileWidth,
				height = self.tileHeight
			}
		end
	end
	
	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Grid:draw()
	for index, tile in pairs(self.matrix) do
		tile:draw()
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
