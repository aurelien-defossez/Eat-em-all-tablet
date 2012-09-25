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

local Collisions = require("src.lib.Collisions")
local Tile = require("src.game.Tile")
local City = require("src.game.City")
local Cemetery = require("src.game.Cemetery")
local FortressWall = require("src.game.FortressWall")
local ManaDrop = require("src.game.ManaDrop")

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
		width = math.floor(self.width / hud.grid.nbCols),
		height = math.floor(self.height / hud.grid.nbRows)
	}

	self.width = Tile.width * hud.grid.nbCols
	self.height = Tile.height * hud.grid.nbRows

	self.x = self.x + math.floor((saveWidth - self.width) / 2)
	self.y = self.y + math.floor((saveHeight - self.height) / 2)

	self.zombies = {}
	self.nbZombies = 0

	self.manaDrops = {}
	self.lastDropSpawnTime = 0	

	self.matrix = {}
	for x = 1, hud.grid.nbRows + 1 do
		for y = 1, hud.grid.nbCols + 1 do
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
	-- Destroy mana drops
	for index, mana in pairs(self.manaDrops) do
		mana:destroy()
	end

	-- Destroy zombies
	for index, zombie in pairs(self.zombies) do
		zombie:destroy()
	end

	-- Destroy tiles
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
			local player = self.players[cemetery.playerId]

			if not config.debug.twoCemeteries or #player.cemeteries == 0 then
				local tile = self:getTile{
					x = cemetery.x,
					y = cemetery.y
				}

				player:addCemetery(Cemetery.create{
					grid = self,
					tile = tile,
					player = player
				})

				placedCemeteries = placedCemeteries + 1
			end
		end
	end

	-- Place fortress walls on edges where there are not any cemetery
	for y = 1, hud.grid.nbRows do
		local leftTile = self:getTile{
			x = 1,
			y = y
		}

		local rightTile = self:getTile{
			x = hud.grid.nbRows + 1,
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

-- Removes a mana drop from the grid
--
-- Parameters
--  mana: The mana drop to remove
function Grid:removeManaDrop(mana)
	self.manaDrops[mana.id] = nil
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
		x = math.floor((parameters.x - self.x) / self.width * hud.grid.nbCols) + 1,
		y = math.floor((parameters.y - self.y) / self.height * hud.grid.nbRows) + 1
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
	if parameters.x > 0 and parameters.x <= hud.grid.nbCols
		and parameters.y > 0 and parameters.y <= hud.grid.nbRows then
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

	-- Relay event to mana drops
	for index, mana in pairs(self.manaDrops) do
		mana:enterFrame(timeDelta)
	end

	-- Create mana drop
	if not config.debug.noManaDrops then
		if config.debug.manaDropFury or self.lastDropSpawnTime >= config.mana.creation.minTime then
			-- pLog = log(ct) / log(max)
			-- pLogInvert = 1 - pLog
			-- pPerSecond = creationFactor / fps
			-- pTotal = pLogInvert * pPerSecond
			local probaFactor = config.mana.creation.factor / config.fps
			local probaSpawn = (1 - math.log(ManaDrop.ct) / math.log(config.mana.maxDrops)) * probaFactor

			if config.debug.manaDropFury then
				probaSpawn = probaSpawn * 2
			end

			if ManaDrop.ct == 0 or math.random() < probaSpawn then
				local middleTileX = math.ceil(hud.grid.nbCols / 2)
				local tile
				local triesCount = 0

				repeat
					tile = self:getTile{
						x = math.random(middleTileX - config.mana.creation.xoffset, middleTileX + config.mana.creation.xoffset),
						y = math.random(hud.grid.nbRows)
					}

					triesCount = triesCount + 1
				until tile:hasNoContent() or tile:hasContentType{TILE.CONTENT.SIGN} or triesCount > 42

				local mana = ManaDrop.create{
					tile = tile,
					grid = self
				}

				self.manaDrops[mana.id] = mana
				self.lastDropSpawnTime = 0
			end
		end
	end

	-- Check for collisions
	for index, zombie in pairs(self.zombies) do
		self:checkZombiesCollsion(zombie)
		self:checkManaCollsion(zombie)
	end

	-- Relay event to zombies
	for index, zombie in pairs(self.zombies) do
		zombie:enterFrame(timeDelta)
	end

	self.lastDropSpawnTime = self.lastDropSpawnTime + timeDelta
end

-- Check for collisions with other zombies
-- Returns as soon as a positive collision has happened
--
-- Parameters:
--  zombie: The zombie to check collisions with
function Grid:checkZombiesCollsion(zombie)
	if zombie.canAttack then
		local mask1 = zombie.collisionMask

		-- Check collision with other zombies
		for otherIndex, otherZombie in pairs(self.zombies) do
			if zombie.player.id ~= otherZombie.player.id and otherZombie.isAttackable then
				local mask2 = otherZombie.collisionMask

				if Collisions.intersectRects(mask1.x, mask1.y, mask1.width, mask1.height,
					mask2.x, mask2.y, mask2.width, mask2.height) then

					local ok = zombie.stateMachine:triggerEvent{
						event = "hitZombie",
						target = otherZombie
					}
					
					if ok then
						return
					end
				end
			end
		end
	end
end

-- Check for collisions with mana drops
-- Returns as soon as a positive collision has happened
--
-- Parameters:
--  zombie: The zombie to check collisions with
function Grid:checkManaCollsion(zombie)
	if zombie.canAttack then
		local mask1 = zombie.collisionMask

		-- Check collision with mana drops
		for index, mana in pairs(self.manaDrops) do
			-- If the mana drop is already being carried, ignore it
			if not mana.zombie then
				local mask2 = mana.collisionMask

				if Collisions.intersectRects(mask1.x, mask1.y, mask1.width, mask1.height,
					mask2.x, mask2.y, mask2.width, mask2.height) then
					
					local ok = zombie.stateMachine:triggerEvent{
						event = "hitMana",
						target = mana
					}
				
					if ok then
						return
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
	return x * hud.grid.nbCols + y
end

-----------------------------------------------------------------------------------------

return Grid
