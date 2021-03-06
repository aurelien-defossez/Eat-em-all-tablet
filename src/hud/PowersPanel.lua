-----------------------------------------------------------------------------------------
--
-- PowersPanel.lua
--
-- The powers panel from which the user can use the powers he bought.
--
-----------------------------------------------------------------------------------------

module("PowersPanel", package.seeall)
PowersPanel.__index = PowersPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local TableLayout = require("src.utils.TableLayout")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

-- Initialize the class
function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the powers panel
--
-- Parameters:
--  player: The powers panel owner
--  grid: The grid
--  x: X position
--  y: Y position
function PowersPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, PowersPanel)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.width = hud.controls.powers.width
	-- self.height = 3 * config.mana.height
	-- self.tableLayout = TableLayout.create{
	-- 	x = self.x,
	-- 	y = self.y,
	-- 	width = self.width,
	-- 	height = self.height,
	-- 	itemWidth = config.mana.width,
	-- 	itemHeight = config.mana.height,
	-- 	nbRows = hud.controls.powers.nbRows,
	-- 	nbCols = hud.controls.powers.nbCols,
	-- 	direction = self.player.tableLayoutDirection
	-- }

	-- Position counter depending on player's side
	local textX
	local spriteX
	if self.player.id == 1 then
		textX = self.width - hud.controls.powers.mana.counter.xoffset
		spriteX = self.width - hud.controls.powers.mana.icon.xoffset
	else
		textX = hud.controls.powers.mana.counter.xoffset
		spriteX = hud.controls.powers.mana.icon.xoffset
	end

	-- Create sprite
	self.manaSprite = Sprite.create{
		spriteSet = SpriteManager.sets.mana,
		group = self.group,
		x = spriteX,
		y = hud.controls.powers.mana.icon.yoffset,
		orientation = self.player.direction
	}

	-- Draw sprite
	self.manaSprite:play("mana_stack")

	-- Create mana counter
	self.manaCounter = display.newText(self.player.mana, 0, 0, native.systemFontBold, 32)
	self.manaCounter.x = textX
	self.manaCounter.y = hud.controls.powers.mana.counter.yoffset
	self.manaCounter:rotate(self.player.direction)
	self.manaCounter:setReferencePoint(display.BottomCenterReferencePoint)
	self.manaCounter:setTextColor(0, 0, 0)
	self.group:insert(self.manaCounter)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Register itself to the player
	self.player.powersPanel = self

	return self
end

-- Destroy the panel
function PowersPanel:destroy()
	-- self.tableLayout:destroy()
	self.manaSprite:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Update the mana counter
--
-- Parameters:
--  mana: The new amount of mana
function PowersPanel:updateMana(mana)
	self.manaCounter.text = mana
end

-----------------------------------------------------------------------------------------

return PowersPanel
