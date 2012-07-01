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
local Arrow = require("Arrow")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	group = display.newGroup()
end

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

	-- Initialize attributes
	self.isOnFirstRow = (self.yGrid == 1)
	self.isOnLastRow = (self.yGrid == config.panels.grid.nbRows)

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

	-- Add to group
	group:insert(borders)
end

-- Check if a pixel is in the tile
--
-- Parameters:
--  x: The X position
--  y: The Y position
--
-- Returns:
--  True if the pixel is inside the tile coordinates
function Tile:isInside(parameters)
	return (parameters.x >= self.x and parameters.x < self.x + self.width
		and parameters.y >= self.y and parameters.y < self.y + self.height)
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  zombie: The zombie entering the tile
function Tile:enterTile(zombie)
	if self.content ~= nil and self.content.enterTile ~= nil then
		self.content:enterTile(zombie)
	end
end

-- Leave tile handler, called when a zombie leaves the tile
--
-- Parameters:
--  zombie: The zombie leaving the tile
function Tile:leaveTile(zombie)
	if self.content ~= nil and self.content.leaveTile ~= nil then
		self.content:leaveTile(zombie)
	end
end

-- Reach middle tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  zombie: The zombie reaching the middle of the tile
function Tile:reachTileMiddle(zombie)
	if self.content ~= nil and self.content.reachTileMiddle ~= nil then
		self.content:reachTileMiddle(zombie)
	end

	-- First or last row tile 
	if self.isOnFirstRow and zombie.direction == Arrow.UP or self.isOnLastRow and zombie.direction == Arrow.DOWN then
		if math.random() < 0.5 then
			zombie:changeDirection(Arrow.LEFT)
		else
			zombie:changeDirection(Arrow.RIGHT)
		end
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
