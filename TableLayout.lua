-----------------------------------------------------------------------------------------
--
-- TableLayout.lua
--
-----------------------------------------------------------------------------------------

module("TableLayout", package.seeall)

TableLayout.__index = TableLayout

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local config = require("GameConfig")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

LEFT_TO_RIGHT = 1
RIGHT_TO_LEFT = 2

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the panel
--
-- Parameters:
--  x: X position
--  y: Y position
--  itemWidth: Item width
--  itemHeight: Item height
--  width: The width
--  height: The height
--  direction: The direction used to fill the table, from left to right or the other way
--  compare: The compare function used to sort objets
function TableLayout.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, TableLayout)
	
	-- Initialize attributes
	self.items = {}
	self.nbRows = math.floor(self.height / self.itemHeight)
	self.nbCols = math.floor(self.width / self.itemWidth)

	return self
end

-- Destroy the panel
function TableLayout:destroy()
	for index, item in ipairs(self.items) do
		item:destroy()
	end
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add an item to the list
--
-- Parameters:
--  item: The new item
function TableLayout:addItem(item)
	self.items[item.id] = item

	self:reorganize()
end

-- Remove an item from the list
--
-- Parameters:
--  item: The item to remove
function TableLayout:removeItem(item)
	self.items[item.id]:destroy()
	self.items[item.id] = nil

	self:reorganize()
end

-- Reorganize items by sorting them by id and moving them accordingly
function TableLayout:reorganize()
	local i = self.direction == LEFT_TO_RIGHT and 0 or self.nbCols - 1
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
			x = self.x + i * self.itemWidth,
			y = self.y + j * self.itemHeight
		}

		j = j + 1

		if j == self.nbRows then
			if self.direction == LEFT_TO_RIGHT then
				i = i + 1
			else
				i = i - 1
			end

			j = 0
		end
	end
end

-- Comparison function for sorting items
function compareLess(a, b)
	return a.id < b.id
end

-----------------------------------------------------------------------------------------

return TableLayout
