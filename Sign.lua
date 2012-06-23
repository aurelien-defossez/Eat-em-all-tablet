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

function Sign.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Sign)

	-- Initialize attributes

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Sign:draw(parameters)
	local spriteName = self.player.id == 1 and "arrow_up_red" or "arrow_up_blue"

	self.sprite = display.newImageRect(spriteName .. ".png", config.arrow.width, config.arrow.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.tile.x + self.tile.width / 2
	self.sprite.y = self.tile.y + self.tile.height / 2
	self.sprite:rotate(self.direction or 0)
end

-----------------------------------------------------------------------------------------

return Sign
