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
	self.items = {}

	-- Register itself to the player
	self.player.itemsPanel = self
	
	return self
end

-- Destroy the panel
function ItemsPanel:destroy()
	for index, item in ipairs(self.items) do
		item:destroy()
	end
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
	self.items[item.id] = item

	self:reorganize()
end

-- Remove an item from the list
--
-- Parameters:
--  item: The item to remove
function ItemsPanel:removeItem(item)
	self.items[item.id]:destroy()
	self.items[item.id] = nil

	self:reorganize()
end

-- Reorganize items by sorting them by obtention order and moving them accordingly
function ItemsPanel:reorganize()
	local i = 0
	local j = 0
	local orderedItems = {}
	
	-- Sort items by id
	for index, item in pairs(self.items) do
		table.insert(orderedItems, item)
	end

	table.sort(orderedItems, compareLess)

	-- Move items to their new place
	for index, item in ipairs(orderedItems) do
		item:moveTo{
			x = self.x + i * config.item.width,
			y = self.y + j * config.item.height
		}

		j = j + 1

		if j == config.panels.controls.items.nbRows then
			i = i + 1
			j = 0
		end
	end
end

-- Comparison function for sorting chortcuts
function compareLess(a, b)
	return a.id < b.id
end

-----------------------------------------------------------------------------------------

return ItemsPanel
