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

require("src.utils.Constants")
require("src.config.GameConfig")

local TableLayout = require("src.utils.TableLayout")
local PlayerItem = require("src.hud.PlayerItem")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the items panel
--
-- Parameters:
--  player: The items panel owner
--  grid: The grid
--  x: X position
--  y: Y position
function ItemsPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ItemsPanel)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
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

	-- Start with items
	if config.debug.startWithItems then
		for key, itemId in pairs({ ITEM.SKELETON, ITEM.GIANT, ITEM.TORNADO, ITEM.MINE }) do
			self.player:gainItem(PlayerItem.create{
				player = self.player,
				grid = self.grid,
				x = self.x,
				y = self.y,
				type = itemId
			})
		end
	end
	
	return self
end

-- Destroy the panel
function ItemsPanel:destroy()
	self.tableLayout:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

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
	self.tableLayout:removeItem(item.id)
end

-----------------------------------------------------------------------------------------

return ItemsPanel
