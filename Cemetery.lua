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

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

function Cemetery.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Cemetery)

	-- Initialize attributes
	self.x = self.tile.x
	self.y = self.tile.y
	self.timeSinceLastSpawn = 0
	self.lastFrameTime = 0

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Cemetery:draw(parameters)
	self.sprite = display.newImageRect("cemetery_" .. self.player.color .. ".png",
		config.cemetery.width, config.cemetery.height)

	-- Position sprite
	self.sprite:setReferencePoint(display.CenterReferencePoint)
	self.sprite.x = self.x + self.tile.width / 2
	self.sprite.y = self.y + self.tile.height / 2
end

function Cemetery:enterFrame(event)
	local deltaTime =  event.time - self.lastFrameTime
	self.timeSinceLastSpawn = self.timeSinceLastSpawn + deltaTime

	if self.timeSinceLastSpawn >= config.cemetery.spawnPeriod then
		self.timeSinceLastSpawn = self.timeSinceLastSpawn - config.cemetery.spawnPeriod
		self:spawn()
	end

	self.lastFrameTime = event.time
end

function Cemetery:spawn()
	print ("spawn (".. self.x .." / " .. self.y.. ")")
end

-----------------------------------------------------------------------------------------

return Cemetery
