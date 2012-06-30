-----------------------------------------------------------------------------------------
--
-- Tile.lua
--
-----------------------------------------------------------------------------------------

module("Tile", package.seeall)

Tile.__index = Tile

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the tile
--
-- Parameters:
--  xGrid: X tile coordinate
--  yGrid: Y tile coordinate
--  x: X pixel coordinate
--  y: Y pixel coordinate
--  width: Tile width
--  height: Tile height
function Tile.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Tile)

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the tile and its content if it exists
function Tile:draw()
	local borders = display.newRect(self.x, self.y, self.width, self.height)
	borders.strokeWidth = config.panels.grid.lineWidth
	borders:setFillColor(122, 47, 15)

	if self.content ~= nil then
		self.content:draw()
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Tile:enterFrame(timeDelta)
	if self.content ~= nil and self.content.enterFrame ~= nil then
		self.content:enterFrame(timeDelta)
	end
end

-----------------------------------------------------------------------------------------

return Tile
