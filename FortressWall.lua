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
local Tile = require("Tile")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

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
	self.type = Tile.TYPE_FORTRESS_WALL
	self.x = self.tile.x
	self.y = self.tile.y

	-- Manage groups
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

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
	self.sprite.x = self.tile.width / 2
	self.sprite.y = self.tile.height / 2

	-- Add to group
	self.group:insert(self.sprite)
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
