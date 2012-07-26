-----------------------------------------------------------------------------------------
--
-- City.lua
--
-----------------------------------------------------------------------------------------

module("City", package.seeall)

City.__index = City

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local SpriteManager = require("SpriteManager")
local Zombie = require("Zombie")
local Tile = require("Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

SIZE_SMALL = 1
SIZE_MEDIUM = 2
SIZE_LARGE = 3

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SpriteManager.SET.CITY)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the city
--
-- Parameters:
--  grid: The grid
--  tile: The tile the city is on
--  size: The city size
--  id: The city unique id
--  name: The city name
function City.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, City)

	-- Initialize attributes
	self.type = Tile.TYPE_CITY
	self.x = self.tile.x
	self.y = self.tile.y
	self.player = nil
	self.gateOpened = false
	self.timeSinceLastSpawn = 0
	self.timeSinceLastExit = 0

	if self.size == SIZE_SMALL then
		self.inhabitants = config.city.small.inhabitants
		self.spawnPeriod = config.city.small.spawnPeriod
		self.maxInhabitants = config.city.small.maxInhabitants
		self.exitPeriod = config.city.small.exitPeriod
	elseif self.size == SIZE_MEDIUM then
		self.inhabitants = config.city.medium.inhabitants
		self.spawnPeriod = config.city.medium.spawnPeriod
		self.maxInhabitants = config.city.medium.maxInhabitants
		self.exitPeriod = config.city.medium.exitPeriod
	else
		self.inhabitants = config.city.large.inhabitants
		self.spawnPeriod = config.city.large.spawnPeriod
		self.maxInhabitants = config.city.large.maxInhabitants
		self.exitPeriod = config.city.large.exitPeriod
	end

	-- Manage groups
	self.cityGroup = display.newGroup()
	self.textGroup = display.newGroup()
	self.group = display.newGroup()

	self.group:insert(self.cityGroup)
	self.group:insert(self.textGroup)
	classGroup:insert(self.group)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	return self
end

-- Destroy the city
function City:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the city
function City:draw()
	-- Draw sprite
	self.citySprite = SpriteManager.newSprite(spriteSet)

	-- Position sprite
	self.citySprite:setReferencePoint(display.CenterReferencePoint)
	self.citySprite.x = self.tile.width / 2
	self.citySprite.y = self.tile.height / 2
	
	-- Handle events
	self.citySprite.city = self
	self.citySprite:addEventListener("touch", onCityTouch)

	-- Insert into group
	self.cityGroup:insert(self.citySprite)

	-- Inhabitants count text
	self.inhabitantsText = display.newText(self.inhabitants, config.city.inhabitantsText.x,
		config.city.inhabitantsText.y, native.systemFontBold, 16)
	self.inhabitantsText:setTextColor(0, 0, 0)

	-- Name text
	self.nameText = display.newText(self.name, config.city.nameText.x, config.city.nameText.y,
		native.systemFontBold, 16)
	self.nameText:setTextColor(0, 0, 0)

	-- Add texts to group
	self.textGroup:insert(self.inhabitantsText)
	self.textGroup:insert(self.nameText)

	self:updateSprite()
end

-- Draw the city sprite
function City:updateSprite()
	local spriteName;
	
	if self.player then
		spriteName = "city" .. self.size .. "_" .. self.player.color
	else
		spriteName = "city" .. self.size .. "_grey"
	end
	
	self.citySprite:prepare(spriteName)
end

-- Add inhabitants to the city
function City:addInhabitants(nb)
	self.inhabitants = self.inhabitants + nb

	if self.inhabitants > self.maxInhabitants then
		self:spawn()
	elseif self.inhabitants == 0 then
		-- Notify player
		if self.player then
			self.player:loseCity(self)
		end

		self.player = nil
		self.gateOpened = false

		self:updateSprite()
	end

	self.inhabitantsText.text = self.inhabitants

	-- Notify shortcut
	if self.shortcut then
		self.shortcut:updateInhabitants()
	end
end

-- Spawn a zombie
function City:spawn()
	local zombie = Zombie.create{
		player = self.player,
		tile = self.tile,
		grid = self.grid
	}

	self.grid:addZombie(zombie)

	zombie:draw()

	self:addInhabitants(-1)
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  zombie: The zombie entering the tile
function City:enterTile(zombie)
	if zombie.phase == Zombie.PHASE_MOVE and (self.player == nil or zombie.player ~= self.player) then
		self:attackCity(zombie)
	end
end

-- Reach middle tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  zombie: The zombie reaching the middle of the tile
function City:reachTileMiddle(zombie)
	if zombie.phase == Zombie.PHASE_MOVE then
		if not self.player or zombie.player ~= self.player then
			self:attackCity(zombie)
		elseif self.inhabitants < self.maxInhabitants and zombie.size == 1 then
			-- Enforce city
			self:addInhabitants(zombie.size)
			zombie:die{
				killer = Zombie.KILLER_CITY_ENTER
			}
		end
	end
end

-- Make the city receive an attack by the given zombie
--
-- Parameters:
--  zombie: The zombie attacking the city
function City:attackCity(zombie)
	if self.inhabitants > 0 then
		-- Attack city and die
		local hits = math.min(zombie.size, self.inhabitants)
		self:addInhabitants(-hits)
		zombie:die{
			killer = Zombie.KILLER_CITY,
			hits = hits
		}
	elseif zombie.size == 1 then
		-- Notify player
		zombie.player:gainCity(self)

		-- Change the city owner
		self.player = zombie.player
		self:addInhabitants(zombie.size)
		zombie:die{
			killer = Zombie.KILLER_CITY_ENTER
		}

		self:updateSprite()
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function City:enterFrame(timeDelta)
	if self.player ~= nil then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeDelta
		self.timeSinceLastExit = self.timeSinceLastExit + timeDelta

		-- Count spawn time
		if self.timeSinceLastSpawn >= self.spawnPeriod then
			self.timeSinceLastSpawn = self.timeSinceLastSpawn - self.spawnPeriod
			self:addInhabitants(1)
		end

		-- Count exit time
		if self.gateOpened then
			if self.timeSinceLastExit >= self.exitPeriod then
				self.timeSinceLastExit = self.timeSinceLastExit - self.exitPeriod
				self:spawn()
			end
		elseif self.timeSinceLastExit > self.exitPeriod then
			-- Prepare next exit
			self.timeSinceLastExit = self.exitPeriod
		end
	end
end

-----------------------------------------------------------------------------------------
-- Private Methods
-----------------------------------------------------------------------------------------

-- Touch handler on a city
function onCityTouch(event)
	local city = event.target.city
	
	-- Open the gates while the finger touches the city
	city.gateOpened = city.player and city.tile:isInside(event)
		and event.phase ~= "ended" and event.phase ~= "cancelled"

	-- Focus this object in order to track this finger properly
	display.getCurrentStage():setFocus(event.target, event.id)
end

-----------------------------------------------------------------------------------------

return City
