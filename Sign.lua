-----------------------------------------------------------------------------------------
--
-- Sign.lua
--
-----------------------------------------------------------------------------------------

module("Sign", package.seeall)

Sign.__index = Sign

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local Tile = require("Tile")
local Arrow = require("Arrow")

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
--  player: The sign owner
--  direction: The sign direction, as arrow direction constant
function Sign.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Sign)

	-- Initialize attributes
	self.type = Tile.TYPE_SIGN
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

-- Destroy the sign
function Sign:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the sign
function Sign:draw()
	self.signSprite = display.newImageRect("arrow_up_" .. self.player.color .. ".png",
		config.arrow.width, config.arrow.height)

	-- Position sprite
	self.signSprite:setReferencePoint(display.CenterReferencePoint)
	self.signSprite.x = self.tile.width / 2
	self.signSprite.y = self.tile.height / 2
	self.signSprite:rotate(self.direction or 0)

	-- Add to group
	self.group:insert(self.signSprite)
end

-- Reach middle tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  zombie: The zombie reaching the middle of the tile
function Sign:reachTileMiddle(zombie)
	if zombie.phase == Zombie.PHASE_MOVE and zombie.player.id == self.player.id then
		-- Ignore special cases
		if not (self.tile.isOnFirstRow and self.direction == Arrow.UP)
			and not (self.tile.isOnLastRow and self.direction == Arrow.DOWN) then
			zombie:changeDirection(self.direction)
		end
	end
end

-----------------------------------------------------------------------------------------

return Sign
