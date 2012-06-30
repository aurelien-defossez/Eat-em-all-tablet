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
