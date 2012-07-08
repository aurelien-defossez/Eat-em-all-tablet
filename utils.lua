-----------------------------------------------------------------------------------------
--
-- utils.lua
--
-----------------------------------------------------------------------------------------

local Arrow = require("Arrow")

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
