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
local Zombie = require("Zombie")

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
	group = display.newGroup()
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
function City.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, City)

	-- Initialize attributes
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

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the city
function City:draw()
	-- Create Z-index groups
	self.cityGroup = display.newGroup()
	self.textGroup = display.newGroup()

	-- Draw city
	self:drawSprite()

	-- Inhabitants count text
	self.inhabitantsText = display.newText(self.inhabitants, self.x + config.city.inhabitantsText.x,
		self.y + config.city.inhabitantsText.y, native.systemFontBold, 16)
	self.inhabitantsText:setTextColor(0, 0, 0)

	-- Size text
	display.newText(self.size, self.x + config.city.sizeText.x, self.y + config.city.sizeText.y,
		native.systemFontBold, 16)

	-- Add to group
	group:insert(self.cityGroup)
	group:insert(self.cityGroup)
end

-- Draw the city sprite
function City:drawSprite()
	local spriteName;

	if self.player then
		spriteName = "city_" .. self.player.color .. ".png"
	else
		spriteName = "city_grey.png"
	end

	-- Create sprite
	self.sprite = display.newImageRect(spriteName, config.city.width, config.city.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x + self.tile.width / 2
	self.sprite.y = self.y + self.tile.height / 2
	
	-- Handle events
	self.sprite.city = self
	self.sprite:addEventListener("touch", onCityTouch)

	-- Insert into group
	self.cityGroup:insert(self.sprite)
end

-- Add inhabitants to the city
function City:addInhabitants(nb)
	self.inhabitants = self.inhabitants + nb

	if self.inhabitants > self.maxInhabitants then
		self:spawn()
	elseif self.inhabitants == 0 then
		self.player = nil
		self:drawSprite()
	end

	self.inhabitantsText.text = self.inhabitants
end

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
	if self.player == nil or zombie.player ~= self.player then
		if self.inhabitants > 0 then
			-- Attack city and die
			self:addInhabitants(-1)
			zombie:die(Zombie.KILLER_CITY)
		else
			-- Change the city owner
			self.player = zombie.player
			self:addInhabitants(1)
			zombie:die(Zombie.KILLER_CITY_ENTER)

			self.sprite:removeSelf()
			self:drawSprite()
		end
	else
		-- Enforce city
		self:addInhabitants(1)
		zombie:die(Zombie.KILLER_CITY_ENTER)
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

	print("event phase="..event.phase)

	-- Open the gates while the finger touches the city
	city.gateOpened = city.player ~= nil and city.tile:isInside(event)
		and event.phase ~= "ended" and event.phase ~= "cancelled"

	if not city.gateOpened then
		city.timeSinceLastExit = 0
	end

	print("gates="..(city.gateOpened and "yes" or "no"))

	-- Focus this object in order to track this finger properly
	display.getCurrentStage():setFocus(event.target, event.id)
end

-----------------------------------------------------------------------------------------

return City
