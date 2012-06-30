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

local collisions = require("collisions")
local config = require("GameConfig")
local Tile = require("Tile")
local Cemetery = require("Cemetery")
local FortressWall = require("FortressWall")
local Zombie = require("Zombie")

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

	self.zombies = {}
	self.nbZombies = 0

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
	local placedCemeteries = 0

	-- Place cemeteries
	for index, cemetery in pairs(parameters.cemeteries) do
		if not config.debug.oneCemetery or placedCemeteries == 0 then
			local tile = self:getTile{
				x = cemetery.x,
				y = cemetery.y
			}

			tile.content = Cemetery.create{
				grid = self,
				tile = tile,
				player = self.players[cemetery.playerId]
			}

			placedCemeteries = placedCemeteries + 1
		end
	end

	-- Place fortress walls on edges where there are not any cemetery
	for y = 1, config.panels.grid.nbRows do
		local leftTile = self:getTile{
			x = 1,
			y = y
		}

		local rightTile = self:getTile{
			x = config.panels.grid.nbRows + 1,
			y = y
		}

		if leftTile.content == nil then
			leftTile.content = FortressWall.create{
				tile = leftTile,
				player = self.players[1]
			}
		end

		if rightTile.content == nil then
			rightTile.content = FortressWall.create{
				tile = rightTile,
				player = self.players[2]
			}
		end
	end
end

-- Draw the grid
function Grid:draw()
	for index, tile in pairs(self.matrix) do
		tile:draw()
	end
end

-- Add a zombie to the list
--
-- Parameters:
--  zombie: The zombie to add
function Grid:addZombie(zombie)
	self.zombies[zombie.id] = zombie
	self.nbZombies = self.nbZombies + 1
end

-- Removes a zombie from the zombies list
--
-- Parameters
--  zombie: The zombie to remove
function Grid:removeZombie(zombie)
	self.zombies[zombie.id] = nil
	self.nbZombies = self.nbZombies - 1
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
--  The corresponding tile, or nil if the coordinates are incorrect
function Grid:getTile(parameters)
	if parameters.x > 0 and parameters.x <= config.panels.grid.nbCols
		and parameters.y > 0 and parameters.y <= config.panels.grid.nbRows then
		return self.matrix[getIndex(parameters.x, parameters.y)]
	else
		return nil
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Grid:enterFrame(timeDelta)
	-- Relay event to tiles
	for index, tile in pairs(self.matrix) do
		tile:enterFrame(timeDelta)
	end

	-- Relay event to zombies
	for index, zombie in pairs(self.zombies) do
		zombie:enterFrame(timeDelta)
	end

	-- Check for collisions
	for index, zombie in pairs(self.zombies) do
		for otherIndex, otherZombie in pairs(self.zombies) do
			if zombie.player.id ~= otherZombie.player.id and otherZombie.id > zombie.id then
				if collisions.intersectRects(zombie.x, zombie.y, zombie.width, zombie.height,
					otherZombie.x, otherZombie.y, otherZombie.width, otherZombie.height) then
					local dyingParameters = {
						killer = Zombie.KILLER_ZOMBIE
					}

					zombie:die(dyingParameters)
					otherZombie:die(dyingParameters)
					
					break
				end
			end
		end
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
