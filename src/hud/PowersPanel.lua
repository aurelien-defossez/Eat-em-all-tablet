-----------------------------------------------------------------------------------------
--
-- PowersPanel.lua
--
-----------------------------------------------------------------------------------------

module("PowersPanel", package.seeall)

PowersPanel.__index = PowersPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local TableLayout = require("src.utils.TableLayout")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	manaSpriteSet = SpriteManager.getSpriteSet(SPRITE_SET.MANA)
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
	self.width = config.panels.controls.powers.width
	-- self.height = 3 * config.mana.height
	-- self.tableLayout = TableLayout.create{
	-- 	x = self.x,
	-- 	y = self.y,
	-- 	width = self.width,
	-- 	height = self.height,
	-- 	itemWidth = config.mana.width,
	-- 	itemHeight = config.mana.height,
	-- 	nbRows = config.panels.controls.powers.nbRows,
	-- 	nbCols = config.panels.controls.powers.nbCols,
	-- 	direction = self.player.tableLayoutDirection
	-- }

	-- Create mana stack icon
	self.manaSprite = SpriteManager.newSprite(manaSpriteSet)
	self.manaSprite.y = config.panels.controls.powers.mana.icon.yoffset
	self.manaSprite:prepare("mana_stack")
	self.manaSprite:play()
	self.group:insert(self.manaSprite)

	-- Create mana counter
	self.manaCounter = display.newText(self.player.mana, 0, 0, native.systemFontBold, 32)
	self.manaCounter.y = config.panels.controls.powers.mana.counter.yoffset
	self.manaCounter:rotate(self.player.direction)
	self.manaCounter:setReferencePoint(display.BottomCenterReferencePoint)
	self.manaCounter:setTextColor(0, 0, 0)
	self.group:insert(self.manaCounter)

	-- Position counter depending on player's side
	if self.player.id == 1 then
		self.manaCounter.x = self.width - config.panels.controls.powers.mana.counter.xoffset
		self.manaSprite.x = self.width - config.panels.controls.powers.mana.icon.xoffset
	else
		self.manaCounter.x = config.panels.controls.powers.mana.counter.xoffset
		self.manaSprite.x = config.panels.controls.powers.mana.icon.xoffset
	end

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Register itself to the player
	self.player.powersPanel = self

	return self
end

-- Destroy the panel
function PowersPanel:destroy()
	self.tableLayout:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function PowersPanel:updateMana(mana)
	self.manaCounter.text = mana
end

-----------------------------------------------------------------------------------------

return PowersPanel
