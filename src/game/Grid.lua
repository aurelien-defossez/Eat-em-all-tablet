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

require("src.utils.Constants")
require("src.config.GameConfig")

local Collisions = require("src.lib.Collisions")
local Tile = require("src.game.Tile")
local City = require("src.game.City")
local Cemetery = require("src.game.Cemetery")
local FortressWall = require("src.game.FortressWall")
local MapItem = require("src.game.MapItem")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

ASCII_CAPITAL_A = 65

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
	Tile.initializeDimensions{
		width = math.floor(self.width / config.panels.grid.nbCols),
		height = math.floor(self.height / config.panels.grid.nbRows)
	}

	self.width = Tile.width * config.panels.grid.nbCols
	self.height = Tile.height * config.panels.grid.nbRows

	self.x = self.x + math.floor((saveWidth - self.width) / 2)
	self.y = self.y + math.floor((saveHeight - self.height) / 2)

	self.zombies = {}
	self.nbZombies = 0

	self.items = {}

	self.timeUntilItemCreation = config.item.creation.time.first

	if config.debug.immediateItemSpawn then
		self.timeUntilItemCreation = 0
	end

	self.matrix = {}
	for x = 1, config.panels.grid.nbRows + 1 do
		for y = 1, config.panels.grid.nbCols + 1 do
			self.matrix[getIndex(x, y)] = Tile.create{
				xGrid = x,
				yGrid = y,
				x = self.x + (x - 1) * Tile.width,
				y = self.y + (y - 1) * Tile.height,
				width = Tile.width,
				height = Tile.height
			}
		end
	end
	
	return self
end

-- Destroy the grid
function Grid:destroy()
	for index, tile in pairs(self.matrix) do
		tile:destroy()
	end
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
--  cities: The list of cities to place, with in each:
--   x: The X tile coordinate
--   y: The Y tile coordinate
--   size: The city size, as City size constant
function Grid:loadMap(parameters)
	local placedCemeteries = 0

	-- Place cemeteries
	for index, cemetery in pairs(parameters.cemeteries) do
		if not config.debug.oneCemetery or placedCemeteries == 0 then
			local tile = self:getTile{
				x = cemetery.x,
				y = cemetery.y
			}

			Cemetery.create{
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

		if leftTile:hasNoContent() then
			FortressWall.create{
				tile = leftTile,
				player = self.players[1]
			}
		end

		if rightTile:hasNoContent() then
			FortressWall.create{
				tile = rightTile,
				player = self.players[2]
			}
		end
	end

	-- Place cities
	local cityId = 1
	for index, city in pairs(parameters.cities) do
		local tile = self:getTile{
			x = city.x,
			y = city.y
		}

		local size
		if city.size == "small" then
			size = CITY.SIZE.SMALL
		elseif city.size == "medium" then
			size = CITY.SIZE.MEDIUM
		else
			size = CITY.SIZE.LARGE
		end

		City.create{
			grid = self,
			tile = tile,
			size = size,
			id = cityId,
			name = string.char(cityId + ASCII_CAPITAL_A - 1)
		}

		cityId = cityId + 1
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

-- Removes an item from the items list
--
-- Parameters
--  item: The item to remove
function Grid:removeItem(item)
	self.items[item.id] = nil
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

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

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

	-- Relay event to items
	for index, item in pairs(self.items) do
		item:enterFrame(timeDelta)
	end

	-- Create item
	self.timeUntilItemCreation = self.timeUntilItemCreation - timeDelta
	if self.timeUntilItemCreation <= 0 then
		local middleTileX = math.ceil(config.panels.grid.nbCols / 2)
		local tile
		local triesCount = 0

		repeat
			tile = self:getTile{
				x = math.random(middleTileX - config.item.creation.xoffset, middleTileX + config.item.creation.xoffset),
				y = math.random(config.panels.grid.nbRows)
			}

			triesCount = triesCount + 1
		until tile:hasNoContent() or tile:hasContentType{TILE.CONTENT.SIGN} or triesCount > 42

		local item = MapItem.create{
			tile = tile,
			grid = self
		}

		self.items[item.id] = item

		self.timeUntilItemCreation = self.timeUntilItemCreation +
			math.random(config.item.creation.time.min, config.item.creation.time.max)
	end

	-- Check for collisions
	for index, zombie in pairs(self.zombies) do
		local mask1 = zombie.collisionMask

		-- Check collision with other zombies
		for otherIndex, otherZombie in pairs(self.zombies) do
			if zombie.player.id ~= otherZombie.player.id and otherZombie.id > zombie.id then
				local mask2 = otherZombie.collisionMask

				if Collisions.intersectRects(mask1.x, mask1.y, mask1.width, mask1.height,
					mask2.x, mask2.y, mask2.width, mask2.height) then

					zombie:die{
						killer = ZOMBIE.KILLER.ZOMBIE,
						hits = otherZombie.size
					}

					otherZombie:die{
						killer = ZOMBIE.KILLER.ZOMBIE,
						hits = zombie.size
					}
					break
				end
			end
		end

		-- Check collision with items
		if zombie.phase == ZOMBIE.PHASE.MOVE and not zombie.isGiant then
			for itemIndex, item in pairs(self.items) do
				-- Determine if the current zombie can make the item carry process faster
				if item.speed < config.item.speed.max and zombie.player.direction == DIRECTION.LEFT
					or item.speed > -config.item.speed.max and zombie.player.direction == DIRECTION.RIGHT then
					local mask2 = item.collisionMask

					if Collisions.intersectRects(mask1.x, mask1.y, mask1.width, mask1.height,
						mask2.x, mask2.y, mask2.width, mask2.height) then
						
						zombie:carryItem(item)
						break
					end
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
function getIndex(x, y)
	return x * config.panels.grid.nbCols + y
end

-----------------------------------------------------------------------------------------

return Grid
