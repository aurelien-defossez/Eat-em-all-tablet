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

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function Player:addHPs(nbHPs)
	self.hitPoints = self.hitPoints + nbHPs

	if self.hitPoints <= 0 then
		print("Player "..self.id.." has lost")
	end
end

-----------------------------------------------------------------------------------------

return Player
