-----------------------------------------------------------------------------------------
--
-- FortressWall.lua
--
-----------------------------------------------------------------------------------------

module("FortressWall", package.seeall)

FortressWall.__index = FortressWall

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates the sign
--
-- Parameters:
--  tile: The tile the sign is on
--  player: The wall owner
function FortressWall.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, FortressWall)

	-- Initialize attributes
	self.x = self.tile.x
	self.y = self.tile.y

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the sign
function FortressWall:draw()
	self.sprite = display.newImageRect("fortress_wall_" .. self.player.color .. ".png",
		config.fortressWall.width, config.fortressWall.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x + self.tile.width / 2
	self.sprite.y = self.y + self.tile.height / 2
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  zombie: The zombie entering the tile
function FortressWall:enterTile(zombie)
	if zombie.player.id ~= self.player.id then
		-- Lose HP
		self.player:addHPs(-1)

		-- Kill zombie
		zombie:die{
			killer = Zombie.KILLER_FORTRESS
		}
	else
		-- Move backward
		zombie:changeDirection(self.player.direction)
	end
end

-----------------------------------------------------------------------------------------

return FortressWall
