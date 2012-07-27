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
	
	return self
end

-- Destroy the player
function Player:destroy()
	-- Do nothing
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add HPs to the player
--
-- Parameters:
--  nbHPs: The number of HPs to add, can be a negative number
function Player:addHPs(nbHPs)
	self.hitPoints = self.hitPoints + nbHPs

	self.hitPointsPanel:updateHPs(self.hitPoints)

	if self.hitPoints <= 0 then
		print("Player " .. self.id .. " has lost")
		GameScene.switchPause()
	end
end

-- Add a city under the control of the player
--
-- Parameters:
--  The city controlled
function Player:gainCity(city)
	self.citiesPanel:gainCity(city)
end

-- Lose the control of a city
--
-- Parameters:
--  The city lost
function Player:loseCity(city)
	self.citiesPanel:loseCity(city)
end

-- Add an item
--
-- Parameters:
--  item: The item
function Player:gainItem(item)
	self.itemsPanel:gainItem(item)
end

-- Remove an item from the list
--
-- Parameters:
--  item: The item to remove
function Player:removeItem(item)
	self.itemsPanel:removeItem(item)
end

-----------------------------------------------------------------------------------------

return Player