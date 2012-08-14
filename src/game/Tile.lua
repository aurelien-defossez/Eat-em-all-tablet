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
-- Class attributes
-----------------------------------------------------------------------------------------

contentId = 0

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
	self.contents = {}

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
	for contentId, content in pairs(self.contents) do
		content:destroy()
	end

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add a content to the tile
--
-- Parameters:
--  content: The content to add to the tile
--
-- Returns:
--  The content id needed to remove it afterward
function Tile:addContent(content)
	contentId = contentId + 1
	self.contents[contentId] = content

	return contentId 
end

-- Remove a content from the tile
--
-- Parameters:
--  contentId: The content id, as given by the addContent method
function Tile:removeContent(contentId)
	self.contents[contentId] = nil
end

-- Tells whether the tile has at least one content
--
-- Returns:
--  True of the tile has ne content
function Tile:hasNoContent()
	return (next(self.contents) == nil)
end

-- Return the first content that matches one of the given content types
--
-- Parameters:
--  contentTypes: The list of content types to look for
--
-- Returns:
--  The first content that matches one of the given content type, or nil otherwise
function Tile:getContentForType(contentTypes)
	for key, contentType in ipairs(contentTypes) do
		for contentId, content in pairs(self.contents) do
			if content.type == contentType then
				return content
			end
		end
	end
	
	return nil
end

-- Tells whether any of the tile contents match one of the given content types
--
-- Parameters:
--  contentTypes: The list of content types to look for
--
-- Returns:
--  True if any content matches one of the given content type
function Tile:hasContentType(contentTypes)
	return (self:getContentForType(contentTypes) ~= nil)
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

-- Add an event listener to this tile
--
-- parameters:
--  name: The event name to listen to
--  object: The object to call the method on
function Tile:addEventListener(name, object)
	self.group:addEventListener(name, object)
end

-- Remove an event listener from this tile
--
-- parameters:
--  name: The event name listened to
--  object: The object provided when adding the event listener
function Tile:removeEventListener(name, object)
	self.group:removeEventListener(name, object)
end

-- Enter tile handler, called when a zombie enters the tile
--
-- Parameters:
--  zombie: The zombie entering the tile
function Tile:enterTile(zombie)
	self.group:dispatchEvent{
		name = TILE.EVENT.ENTER_TILE,
		zombie = zombie
	}
end

-- Leave tile handler, called when a zombie leaves the tile
--
-- Parameters:
--  zombie: The zombie leaving the tile
function Tile:leaveTile(zombie)
	self.group:dispatchEvent{
		name = TILE.EVENT.LEAVE_TILE,
		zombie = zombie
	}
end

-- Reach center tile handler, called when a zombie reaches the middle of the tile
--
-- Parameters:
--  zombie: The zombie reaching the middle of the tile
function Tile:reachTileCenter(zombie)
	self.group:dispatchEvent{
		name = TILE.EVENT.REACH_TILE_CENTER,
		zombie = zombie
	}

	-- First or last row tile 
	if self.isOnFirstRow and zombie.direction == DIRECTION.UP
		or self.isOnLastRow and zombie.direction == DIRECTION.DOWN then
		if math.random() < 0.5 then
			zombie:changeDirection{
				direction = DIRECTION.LEFT,
				correctPosition = true
			}
		else
			zombie:changeDirection{
				direction = DIRECTION.RIGHT,
				correctPosition = true
			}
		end
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Tile:enterFrame(timeDelta)
	for contentId, content in pairs(self.contents) do
		if content.enterFrame then
			content:enterFrame(timeDelta)
		end
	end
end

-----------------------------------------------------------------------------------------

return Tile
