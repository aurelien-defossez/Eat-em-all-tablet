-----------------------------------------------------------------------------------------
--
-- Zombie.lua
--
-----------------------------------------------------------------------------------------

module("Zombie", package.seeall)

Zombie.__index = Zombie

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

UP = { x = 0, y = -1 }
DOWN = { x = 0, y = 1 }
LEFT = { x = -1, y = 0 }
RIGHT = { x = 1, y = 0 }

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 0

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Zombie.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Zombie)

	-- Initialize attributes
	ctId = ctId + 1
	self.id = ctId
	self.width = config.zombie.width
	self.height = config.zombie.height
	self.x = self.cemetery.x + self.width / 2
	self.y = self.cemetery.y + self.height / 2
	self.direction = self.player.direction == "right" and RIGHT or LEFT

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Zombie:draw()
	self.sprite = display.newImageRect("zombie_" .. self.player.color .. ".png", self.width, self.height)
	self.sprite.arrow = self

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x
	self.sprite.y = self.y
end

function Zombie:enterFrame(timeDelta)
	local movement = timeDelta / 1000 * config.zombie.speed * self.cemetery.tile.width

	self.x = self.x + movement * self.direction.x
	self.y = self.y + movement * self.direction.y

	self.sprite.x = self.x
	self.sprite.y = self.y
end

-----------------------------------------------------------------------------------------

return Zombie
