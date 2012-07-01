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

INHABITANTS_SMALL = 5
INHABITANTS_MEDIUM = 15
INHABITANTS_LARGE = 40

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

	if self.size == SIZE_SMALL then
		self.inhabitants = INHABITANTS_SMALL
	elseif self.size == SIZE_MEDIUM then
		self.inhabitants = INHABITANTS_MEDIUM
	else
		self.inhabitants = INHABITANTS_LARGE
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
	self:drawCity()

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

function City:drawCity()
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

	self.cityGroup:insert(self.sprite)
end

function City:addInhabitants(nb)
	self.inhabitants = self.inhabitants + nb
	self.inhabitantsText.text = self.inhabitants
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
			self:drawCity()
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
	
end

-----------------------------------------------------------------------------------------

return City
