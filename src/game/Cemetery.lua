-----------------------------------------------------------------------------------------
--
-- Cemetery.lua
--
-----------------------------------------------------------------------------------------

module("Cemetery", package.seeall)

Cemetery.__index = Cemetery

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local Zombie = require("src.game.Zombie")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.CEMETERY)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the cemetery
--
-- Parameters:
--  grid: The grid
--  tile: The tile the cemetery is on
--  player: The cemetery owner
function Cemetery.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Cemetery)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.type = TILE.CONTENT.CEMETERY
	self.x = self.tile.x
	self.y = self.tile.y
	self.timeSinceLastSpawn = 0
	self.timeSinceLastQuickSpawn = 0
	self.nbQuickZombies = 0

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	if config.debug.immediateSpawn then
		self.timeSinceLastSpawn = config.cemetery.spawnPeriod.normal
	end
	
	-- Draw the sprite
	self.cemeterySprite = SpriteManager.newSprite(spriteSet)
	self.cemeterySprite:prepare("cemetery_" .. self.player.color.name)
	self.cemeterySprite:play()

	-- Position sprite
	self.cemeterySprite:setReferencePoint(display.CenterReferencePoint)
	self.cemeterySprite.x = Tile.width_2
	self.cemeterySprite.y = Tile.height_2

	-- Add to group
	self.group:insert(self.cemeterySprite)

	-- Register to the tile
	self.contentId = self.tile:addContent(self)

	-- Listen to events
	self.tile:addEventListener(TILE.EVENT.ENTER_TILE, self)
	Runtime:addEventListener("spritePause", self)

	return self
end

-- Destroy the cemetery
function Cemetery:destroy()
	self.tile:removeEventListener(TILE.EVENT.ENTER_TILE, self)
	Runtime:removeEventListener("spritePause", self)

	self.tile:removeContent(self.contentId)

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Spawn a single zombie
--
-- Parameters:
--  size: The zombie size (default = 1)
function Cemetery:spawn(parameters)
	if not config.debug.oneZombie or self.grid.nbZombies == 0 then
		local zombie = Zombie.create{
			player = self.player,
			tile = self.tile,
			grid = self.grid,
			size = parameters.size or 1
		}

		self.grid:addZombie(zombie)
	end
end

-- Quickly spawn n zombies
--
-- Parameters
--  nbZombies: The number of zombies to spawn
function Cemetery:quicklySpawnZombies(nbZombies)
	self.nbQuickZombies = self.nbQuickZombies + nbZombies
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  event: The tile event, with these values:
--   zombie: The zombie entering the tile
function Cemetery:enterTile(event)
	local zombie = event.zombie

	if zombie.player.id ~= self.player.id then
		zombie.stateMachine:triggerEvent{
			event = "hitEnemyCemetery",
			target = self
		}
	else
		zombie.stateMachine:triggerEvent{
			event = "hitFriendlyCemetery",
			target = self
		}
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Cemetery:enterFrame(timeDelta)
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + timeDelta
	self.timeSinceLastQuickSpawn = self.timeSinceLastQuickSpawn + timeDelta

	-- Count spawn time
	if self.timeSinceLastSpawn >= config.cemetery.spawnPeriod.normal then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn - config.cemetery.spawnPeriod.normal

		local size = 1
		if config.debug.onlyGiants or config.debug.randomGiants and math.random() < 0.2 then
			size = config.item.giant.size
		end

		self:spawn{
			size = size
		}
	end

	-- Count quick spawn time
	if self.nbQuickZombies == 0 then
		self.timeSinceLastQuickSpawn = math.min(self.timeSinceLastQuickSpawn, config.cemetery.spawnPeriod.quick)
	elseif self.timeSinceLastQuickSpawn >= config.cemetery.spawnPeriod.quick then
		self.timeSinceLastQuickSpawn = self.timeSinceLastQuickSpawn - config.cemetery.spawnPeriod.quick
		self.nbQuickZombies = self.nbQuickZombies - 1
		self:spawn{
			size = 1
		}
	end
end

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function Cemetery:spritePause(event)
	if event.status then
		self.cemeterySprite:pause()
	else
		self.cemeterySprite:play()
	end
end

-----------------------------------------------------------------------------------------

return Cemetery
