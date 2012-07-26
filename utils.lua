-----------------------------------------------------------------------------------------
--
-- utils.lua
--
-----------------------------------------------------------------------------------------

local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return the reverse direction of the one given
--
-- Parameters:
--  direction: The direction as an Arrow constant
--
-- Returns:
--  The reverse direction, as an Arrow constant
function getReverseDirection(direction)
	if direction == Arrow.UP then
		return Arrow.DOWN
	elseif direction == Arrow.DOWN then
		return Arrow.UP
	elseif direction == Arrow.LEFT then
		return Arrow.RIGHT
	elseif direction == Arrow.RIGHT then
		return Arrow.LEFT
	end
end
