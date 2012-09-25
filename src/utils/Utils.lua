-----------------------------------------------------------------------------------------
--
-- Utils.lua
--
-- Some utils functions
--
-----------------------------------------------------------------------------------------

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
