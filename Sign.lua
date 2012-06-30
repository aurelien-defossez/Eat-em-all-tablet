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
local Arrow = require("Arrow")

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
	self.x = self.tile.x
	self.y = self.tile.y

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the sign
function Sign:draw()
	self.sprite = display.newImageRect("arrow_up_" .. self.player.color .. ".png",
		config.arrow.width, config.arrow.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x + self.tile.width / 2
	self.sprite.y = self.y + self.tile.height / 2
	self.sprite:rotate(self.direction or 0)
end

-- Reach middle tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  zombie: The zombie reaching the middle of the tile
function Sign:reachTileMiddle(zombie)
	if zombie.player.id == self.player.id then
		-- Ignore special cases
		if not (self.tile.isOnFirstRow and self.direction == Arrow.UP)
			and not (self.tile.isOnLastRow and self.direction == Arrow.DOWN) then
			zombie:changeDirection(self.direction)
		end
	end
end

-----------------------------------------------------------------------------------------

return Sign
