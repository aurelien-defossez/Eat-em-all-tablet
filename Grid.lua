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
local Cemetery = require("Cemetery")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the grid
--
-- Parameters:
-- players: The two player objects
--  x: X position of the grid
--  y: Y position of the grid
--  width: Maximum allocable width of the grid (the real width will depend on the screen size and tile size)
--  height: Maximum allocable height (same)
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

-- Load a map, with cemeteries and cities
--
-- Parameters:
--  cemeteries: The list of cemeteries to place, with in each:
--   x: The X tile coordinate
--   y: The Y tile coordinate
--   playerId: The owner id
function Grid:loadMap(parameters)
	-- Place cemeteries
	for index, cemetery in pairs(parameters.cemeteries) do
		local tile = self:getTile{
			x = cemetery.x,
			y = cemetery.y
		}

		tile.content = Cemetery.create{
			grid = self,
			tile = tile,
			player = self.players[cemetery.playerId]
		}
	end
end

-- Draw the grid
function Grid:draw()
	for index, tile in pairs(self.matrix) do
		tile:draw()
	end
end

-- Get a tile using pixel coordinates
-- 
-- Parameters:
--  x: X coordinate value
--  y: Y coordinate value
--
-- Returns:
--  The corresponding tile
function Grid:getTileByPixels(parameters)
	return self:getTile{
		x = math.floor((parameters.x - self.x) / self.width * config.panels.grid.nbCols) + 1,
		y = math.floor((parameters.y - self.y) / self.height * config.panels.grid.nbRows) + 1
	}
end

-- Get a tile using tile coordinates
--
-- Parameters:
--  x: X tile coordinate
--  y: Y tile coordinate
--
-- Returns:
--  The corresponding tile
function Grid:getTile(parameters)
	return self.matrix[getIndex(parameters.x, parameters.y)]
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Grid:enterFrame(timeDelta)
	for index, tile in pairs(self.matrix) do
		tile:enterFrame(timeDelta)
	end
end

-----------------------------------------------------------------------------------------
-- Local methods
-----------------------------------------------------------------------------------------

-- Calculate the 1-D array index from 2-D coordinates
--
-- Parameters:
--  x: X tile coordinate
--  y: Y tile coordinate
--
--
-- Returns:
--  The 1-D array index
function Grid.getIndex(x, y)
	return x * config.panels.grid.nbCols + y
end

-----------------------------------------------------------------------------------------

return Grid
