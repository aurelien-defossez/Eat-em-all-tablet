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

require("src.utils.Constants")
require("src.config.GameConfig")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

function initializeDimensions(parameters)
	width = parameters.width
	height = parameters.height
	width_2 = width / 2
	height_2 = height / 2
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

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.isOnFirstRow = (self.yGrid == 1)
	self.isOnLastRow = (self.yGrid == config.panels.grid.nbRows)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw borders
	local borders = display.newRect(0, 0, self.width, self.height)
	borders.strokeWidth = config.panels.grid.lineWidth
	borders:setFillColor(122, 47, 15)

	-- Add to group
	self.group:insert(borders)

	return self
end

-- Destroy the tile
function Tile:destroy()
	if self.content then
		self.content:destroy()
	end

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Return the content type, if exist
--
-- Returns:
--  The content type, as defined by the cell content, if cell has content
function Tile:getContentType()
	if self.content then
		return self.content.type
	else
		return nil
	end
end

-- Remove the tile content, if exists
function Tile:removeContent()
	if self.content then
		if self.content.destroy then
			self.content:destroy()
		end

		self.content = nil
	end
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
	if self.content and self.content.enterTile then
		self.content:enterTile(zombie)
	end
end

-- Leave tile handler, called when a zombie leaves the tile
--
-- Parameters:
--  zombie: The zombie leaving the tile
function Tile:leaveTile(zombie)
	if self.content and self.content.leaveTile then
		self.content:leaveTile(zombie)
	end
end

-- Reach middle tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  zombie: The zombie reaching the middle of the tile
function Tile:reachTileMiddle(zombie)
	if self.content and self.content.reachTileMiddle then
		self.content:reachTileMiddle(zombie)
	end

	-- First or last row tile 
	if self.isOnFirstRow and zombie.direction == DIRECTION.UP
		or self.isOnLastRow and zombie.direction == DIRECTION.DOWN then
		if math.random() < 0.5 then
			zombie:changeDirection(DIRECTION.LEFT)
		else
			zombie:changeDirection(DIRECTION.RIGHT)
		end
	end
end

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Tile:enterFrame(timeDelta)
	if self.content and self.content.enterFrame then
		self.content:enterFrame(timeDelta)
	end
end

-----------------------------------------------------------------------------------------

return Tile