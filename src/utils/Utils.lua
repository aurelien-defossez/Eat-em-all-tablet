-----------------------------------------------------------------------------------------
--
-- Utils.lua
--
-----------------------------------------------------------------------------------------

require("src.config.GameConfig")
require("src.utils.Constants")

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return the reverse direction of the one given
--
-- Parameters:
--  direction: The direction as an DIRECTION constant
--
-- Returns:
--  The reverse direction, as an DIRECTION constant
function getReverseDirection(direction)
	if direction == DIRECTION.UP then
		return DIRECTION.DOWN
	elseif direction == DIRECTION.DOWN then
		return DIRECTION.UP
	elseif direction == DIRECTION.LEFT then
		return DIRECTION.RIGHT
	elseif direction == DIRECTION.RIGHT then
		return DIRECTION.LEFT
	end
end

-- Print the currently activated debug functions
function printDebugMessages()
	if config.debug.oneCemetery then
		print("Debug: Only one cemetery created")
	end

	if config.debug.oneZombie then
		print("Debug: Only one zombie will be on the map at a time")
	end

	if config.debug.randomGiants then
		print("Debug: Giants will spawn randomly from cemeteries")
	end

	if config.debug.fastZombies then
		print("Debug: Zombies move three times faster than usual")
	end

	if config.debug.immediateSpawn then
		print("Debug: First zombies are spawning immediately")
	end

	if config.debug.immediateItemSpawn then
		print("Debug: First item is created immediately")
	end

	if config.debug.showCollisionMask then
		print("Debug: Collision masks are shown")
	end

	if config.debug.startWithItems then
		print("Debug: Starting with the four different items")
	end

	if config.debug.frameByFrame then
		print("Debug:Frame by frame mode enabled")
	end
end
