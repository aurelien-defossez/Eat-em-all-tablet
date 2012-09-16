-----------------------------------------------------------------------------------------
--
-- Player.lua
--
-----------------------------------------------------------------------------------------

module("Player", package.seeall)

Player.__index = Player

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")

local GameScene = require("src.game.GameScene")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the player
--
-- Parameters:
--  id: The player id,
--  color: The player color, used to load correct sprites
--  direction: The default direction for new zombies
--  hitPoints: The number of hit points
function Player.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Player)

	-- Initialize attributes
	self.signs = {}
	self.signsCount = 0
	self.cemeteries = {}
	self.itemCount = 0
	
	return self
end

-- Destroy the player
function Player:destroy()
	-- Do nothing
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add a cemetery to the player
--
-- Parameters:
--  cemetery: The cemetery to add
function Player:addCemetery(cemetery)
	table.insert(self.cemeteries, cemetery)
end

-- Add HPs to the player
--
-- Parameters:
--  nbHPs: The number of HPs to add, can be a negative number
function Player:addHPs(nbHPs)
	self.hitPoints = self.hitPoints + nbHPs

	self.hitPointsPanel:updateHPs(self.hitPoints)

	if self.hitPoints <= 0 then
		print("Player " .. self.id .. " has lost")
		Runtime:dispatchEvent{
			name = "gamePause",
			status = true
		}
	end
end

-- Add a city under the control of the player
--
-- Parameters:
--  The city controlled
function Player:gainCity(city)
	-- Do nothring
end

-- Lose the control of a city
--
-- Parameters:
--  The city lost
function Player:loseCity(city)
	-- Do nothring
end

-- Add an item
--
-- Parameters:
--  item: The item
function Player:gainItem(item)
	self.itemsPanel:gainItem(item)
	self.itemCount = self.itemCount + 1
end

-- Remove an item from the list
--
-- Parameters:
--  item: The item to remove
function Player:removeItem(item)
	self.itemsPanel:removeItem(item)
	self.itemCount = self.itemCount - 1
end

-- Add a sign under the control of the player
--
-- Parameters:
--  newSign: The new sign
function Player:addSign(newSign)
	self.signs[newSign.id] = newSign
	self.signsCount = self.signsCount + 1

	if self.signsCount == config.player.maxSigns then
		self.arrowsPanel:disable()
	end

	-- Display number of remaining signs
	self.arrowsPanel:updateSignCount(config.player.maxSigns - self.signsCount)
end

-- Remove a sign from the player's control
--
-- Parameters:
--  sign: The sign to remove
function Player:removeSign(sign)
	self.signs[sign.id] = nil
	self.signsCount = self.signsCount - 1

	if self.signsCount == config.player.maxSigns - 1 then
		self.arrowsPanel:enable()
	end

	-- Display number of remaining signs
	self.arrowsPanel:updateSignCount(config.player.maxSigns - self.signsCount)
end

-----------------------------------------------------------------------------------------

return Player
