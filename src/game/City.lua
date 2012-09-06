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

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Zombie = require("src.game.Zombie")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.CITY)
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

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.CITY
	self.x = self.tile.x
	self.y = self.tile.y
	self.player = nil
	self.gateOpened = false

	self.timeSinceLastSpawn = 0
	self.timeSinceLastExit = 0

	if self.size == CITY.SIZE.SMALL then
		self.inhabitants = config.city.small.inhabitants
		self.spawnPeriod = config.city.small.spawnPeriod
		self.maxInhabitants = config.city.small.maxInhabitants
		self.exitPeriod = config.city.small.exitPeriod
	elseif self.size == CITY.SIZE.MEDIUM then
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

	-- Add to groups
	self.cityGroup = display.newGroup()
	self.barGroup = display.newGroup()

	self.group:insert(self.cityGroup)
	self.group:insert(self.barGroup)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Create sprite
	self.citySprite = SpriteManager.newSprite(spriteSet)

	-- Position sprite
	self.citySprite:setReferencePoint(display.CenterReferencePoint)
	self.citySprite.x = self.tile.width / 2
	self.citySprite.y = self.tile.height / 2

	-- Bars
	self.barHeight = config.city.bars.maxHeight * self.maxInhabitants / config.city.large.maxInhabitants
	self.pixelsPerInhabitant = self.maxInhabitants / self.barHeight

	self.backgroundBar = display.newRect(0, 0, 0, 0)
	self.backgroundBar.width = config.city.bars.width
	self.backgroundBar.height = self.barHeight
	self.backgroundBar:setReferencePoint(display.BottomLeftReferencePoint)
	self.backgroundBar.x = config.city.bars.offset.x
	self.backgroundBar.y = config.city.bars.offset.y + config.city.bars.maxHeight
	self.backgroundBar.strokeWidth = 0
	self.backgroundBar:setFillColor(165, 165, 165)
	self.backgroundBar:setStrokeColor(20, 20, 20)

	self.inhabitantsBar = display.newRect(0, 0, 0, 0)
	self.inhabitantsBar.width = config.city.bars.width
	self.inhabitantsBar.strokeWidth = 0

	self:updateInhabitants()

	-- Add to group
	self.cityGroup:insert(self.citySprite)
	self.barGroup:insert(self.backgroundBar)
	self.barGroup:insert(self.inhabitantsBar)
	
	-- Handle events
	self.citySprite:addEventListener("touch", self)

	-- Play neutral animation
	self:updateSprite()

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.ENTER_TILE, self)
	self.tile:addEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	Runtime:addEventListener("spritePause", self)

	return self
end

-- Destroy the city
function City:destroy()
	self.tile:removeEventListener(TILE.EVENT.ENTER_TILE, self)
	self.tile:removeEventListener(TILE.EVENT.REACH_TILE_CENTER, self)
	Runtime:removeEventListener("spritePause", self)

	self.tile:removeContent(self.contentId)

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Update the city sprite animation
function City:updateSprite()
	local animationName;
	
	if self.player then
		animationName = "city" .. self.size .. "_" .. self.player.color.name
		self.inhabitantsBar:setFillColor(self.player.color.r, self.player.color.g, self.player.color.b)
	else
		animationName = "city" .. self.size .. "_grey"
		self.inhabitantsBar:setFillColor(57, 57, 57)
	end
	
	self.citySprite:prepare(animationName)
	self.citySprite:play()
end

-- Update the number of inhabitants graphically
function City:updateInhabitants()
	local newHeight = self.barHeight - (1 - (self.inhabitants / self.maxInhabitants)) * self.barHeight
	
	self.inhabitantsBar.height = newHeight
	self.inhabitantsBar.isVisible = (newHeight > 0)

	self.inhabitantsBar:setReferencePoint(display.BottomLeftReferencePoint)
	self.inhabitantsBar.x = config.city.bars.offset.x
	self.inhabitantsBar.y = config.city.bars.offset.y + config.city.bars.maxHeight
end

-- Add inhabitants to the city
function City:addInhabitants(nb)
	print("addInhabitants "..nb)
	self.inhabitants = self.inhabitants + nb

	if self.inhabitants > self.maxInhabitants then
		self:spawn{
			free = false
		}
	elseif self.inhabitants == 0 then
		-- Notify player
		if self.player then
			self.player:loseCity(self)
		end

		self.player = nil
		self.gateOpened = false

		self:updateSprite()
	end

	self:updateInhabitants()

	-- Notify shortcut
	if self.shortcut then
		self.shortcut:updateInhabitants()
	end
end

-- Spawn a zombie
--
-- Parameters:
--  free: If true, then this spawn is free and does not take an inhabitant
function City:spawn(parameters)
	local zombie = Zombie.create{
		player = self.player,
		tile = self.tile,
		grid = self.grid
	}

	self.grid:addZombie(zombie)

	if not parameters.free then
		self:addInhabitants(-1)
	end
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function City:enterTile(event)
	local zombie = event.zombie
	
	if zombie.phase == ZOMBIE.PHASE.MOVE then
		if not self.player or zombie.player ~= self.player then
			self:attackCity(zombie)
		elseif self.inhabitants < self.maxInhabitants and zombie.size == 1 then
			-- Enforce city
			self:addInhabitants(zombie.size)
			zombie:die{
				killer = ZOMBIE.KILLER.CITY_ENTER
			}
		end
	end
end

-- Reach center tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function City:reachTileCenter(event)
	local zombie = event.zombie

	if zombie.phase == ZOMBIE.PHASE.MOVE and self.player and zombie.player.id == self.player.id then
		zombie:changeDirection{
			direction = self.player.direction,
			priority = ZOMBIE.PRIORITY.CITY,
			correctPosition = true
		}
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
			killer = ZOMBIE.KILLER.CITY,
			hits = hits
		}
	elseif not zombie.isGiant then
		-- Notify player
		zombie.player:gainCity(self)

		-- Change the city owner
		self.player = zombie.player
		self:addInhabitants(zombie.size)
		zombie:die{
			killer = ZOMBIE.KILLER.CITY_ENTER
		}

		self:updateSprite()
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function City:enterFrame(timeDelta)
	if self.player then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeDelta
		self.timeSinceLastExit = self.timeSinceLastExit + timeDelta

		-- Count spawn time
		if self.timeSinceLastSpawn >= self.spawnPeriod then
			self.timeSinceLastSpawn = self.timeSinceLastSpawn - self.spawnPeriod
			self:spawn{
				free = true
			}
		end

		-- Count exit time
		if self.gateOpened then
			if self.timeSinceLastExit >= self.exitPeriod then
				self.timeSinceLastExit = self.timeSinceLastExit - self.exitPeriod
				self:spawn{
					free = false
				}
			end
		elseif self.timeSinceLastExit > self.exitPeriod then
			-- Prepare next exit
			self.timeSinceLastExit = self.exitPeriod
		end
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Touch handler on a city
--
-- Parameters:
--  event: The touch event
function City:touch(event)
	-- Open the gates while the finger touches the city
	self.gateOpened = self.tile:isInside(event)
		and event.phase ~= "ended" and event.phase ~= "cancelled"

	-- Focus this object in order to track this finger properly
	display.getCurrentStage():setFocus(event.target, event.id)
	
	return true
end

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function City:spritePause(event)
	if event.status then
		self.citySprite:pause()
	else
		self.citySprite:play()
	end
end

-----------------------------------------------------------------------------------------

return City
