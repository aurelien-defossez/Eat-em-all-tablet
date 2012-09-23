-----------------------------------------------------------------------------------------
--
-- UpgradePanel.lua
--
-----------------------------------------------------------------------------------------

module("UpgradePanel", package.seeall)

UpgradePanel.__index = UpgradePanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	miscSpriteSet = SpriteManager.getSpriteSet(SPRITE_SET.MISC)
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the upgrade panel
--
-- Parameters:
--  player: The upgrade panel owner
--  x: X position
--  y: Y position
function UpgradePanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, UpgradePanel)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.width = config.panels.controls.upgrade.width
	self.height = config.panels.controls.upgrade.height

	-- Create background
	self.background = display.newRoundedRect(0, -10, self.width, self.height + 10, 10)
	self.background.strokeWidth = 2
	self.background:setFillColor(240, 150, 0)
	self.background:setStrokeColor(255, 255, 255)
	self.group:insert(self.background)

	-- Create sprite
	self.upgradeSprite1 = Sprite.create{
		spriteSet = miscSpriteSet,
		group = self.group,
		x = config.panels.controls.upgrade.icon.width,
		y = config.panels.controls.upgrade.icon.height,
		orientation = 180
	}

	self.upgradeSprite2 = Sprite.create{
		spriteSet = miscSpriteSet,
		group = self.group,
		x = self.width - config.panels.controls.upgrade.icon.width,
		y = config.panels.controls.upgrade.icon.height,
		orientation = 180
	}

	-- Draw sprites
	self.upgradeSprite1:play("upgrade")
	self.upgradeSprite2:play("upgrade")

	-- Create XP counter
	self.xpCounter = display.newText(self.player.xp, 0, 0, native.systemFontBold, 28)
	self.xpCounter:setReferencePoint(display.CenterReferencePoint)
	self.xpCounter:rotate(self.player.direction)
	self.xpCounter.x = self.width / 2
	self.xpCounter.y = self.height / 2
	self.xpCounter:setTextColor(0, 0, 0)
	self.group:insert(self.xpCounter)

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Register itself to the player
	self.player.upgradePanel = self

	return self
end

-- Destroy the panel
function UpgradePanel:destroy()
	self.upgradeSprite1:destroy()
	self.upgradeSprite2:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function UpgradePanel:updateXp(xp)
	self.xpCounter.text = xp
end

-----------------------------------------------------------------------------------------

return UpgradePanel
