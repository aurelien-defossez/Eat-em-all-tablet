-----------------------------------------------------------------------------------------
--
-- ItemsPanel.lua
--
-----------------------------------------------------------------------------------------

module("ItemsPanel", package.seeall)

ItemsPanel.__index = ItemsPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")
local TableLayout = require("TableLayout")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the items panel
--
-- Parameters:
--  player: The items panel owner
--  x: X position
--  y: Y position
function ItemsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ItemsPanel)
	
	-- Initialize attributes
	self.width = config.panels.controls.items.width
	self.height = 3 * config.item.height
	self.tableLayout = TableLayout.create{
		x = self.x,
		y = self.y,
		width = self.width,
		height = self.height,
		itemWidth = config.item.width,
		itemHeight = config.item.height,
		direction = self.player.tableLayoutDirection
	}

	-- Register itself to the player
	self.player.itemsPanel = self
	
	return self
end

-- Destroy the panel
function ItemsPanel:destroy()
	self.tableLayout:destroy()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Draw the cities panel
function ItemsPanel:draw()
	-- Nothing to draw
end

-- Add an item to the player
--
-- Parameters:
--  item: The new item
function ItemsPanel:gainItem(item)
	self.tableLayout:addItem(item)
end

-- Remove an item from the list
--
-- Parameters:
--  item: The item to remove
function ItemsPanel:removeItem(item)
	self.tableLayout:removeItem(item)
end

-----------------------------------------------------------------------------------------

return ItemsPanel
