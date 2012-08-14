-----------------------------------------------------------------------------------------
--
-- UpperBarPanel.lua
--
-----------------------------------------------------------------------------------------

module("UpperBarPanel", package.seeall)

UpperBarPanel.__index = UpperBarPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local MenuWindow = require("src.hud.MenuWindow")
local Button = require("src.hud.Button")
local WindowManager = require("src.utils.WindowManager")
local HitPointsPanel = require("src.hud.HitPointsPanel")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.MISC)

	HitPointsPanel.initialize()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the upper bar panel
--
-- Parameters:
--  players: The two players
function UpperBarPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, UpperBarPanel)
	
	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.height = config.panels.upperBar.height
	self.hpWidth = (config.screen.width - config.panels.upperBar.menuButton.width) / 2

	self.hitPoints = {}
	self.hitPoints[1] = HitPointsPanel.create{
		maxHitPoints = self.players[1].hitPoints,
		hitPoints = self.players[1].hitPoints,
		x = 0,
		y = 0,
		width = self.hpWidth,
		direction = HIT_POINTS_PANEL.DIRECTION.FORWARD
	}

	self.hitPoints[2] = HitPointsPanel.create{
		maxHitPoints = self.players[2].hitPoints,
		hitPoints = self.players[2].hitPoints,
		x = self.hpWidth + config.panels.upperBar.menuButton.width,
		y = 0,
		width = self.hpWidth,
		direction = HIT_POINTS_PANEL.DIRECTION.REVERSE
	}

	self.players[1].hitPointsPanel = self.hitPoints[1]
	self.players[2].hitPointsPanel = self.hitPoints[2]

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw pause button
	self.pauseSprite = SpriteManager.newSprite(spriteSet)
	self.pauseSprite:prepare("pause")
	self.pauseSprite:play()

	-- Position sprite
	self.pauseSprite:setReferencePoint(display.CenterReferencePoint)
	self.pauseSprite.x = self.hpWidth + config.panels.upperBar.menuButton.width / 2
	self.pauseSprite.y = config.panels.upperBar.height / 2

	-- Add listener on pause tap
	self.pauseSprite:addEventListener("tap", onPauseTap)

	-- Add to group
	self.group:insert(self.pauseSprite)
	
	return self
end

-- Destroy the panel
function UpperBarPanel:destroy()
	self.hitPoints[1]:destroy()
	self.hitPoints[2]:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Tap handler on the pause button
--
-- Parameters:
--  event: The event thrown
function onPauseTap(event)
	local window = WindowManager.getTopWindow()

	if not window then
		Runtime:dispatchEvent{
			name = "gamePause",
			system = false,
			status = true
		}

		WindowManager.addWindow(MenuWindow.create{
			title = "Pause",
			onClose = onClose,
			buttons = {
				Button.create{
					text = "Resume",
					actionPerformed = onResumeTap
				},
				Button.create{
					text = "Restart",
					actionPerformed = onRestartTap
				},
				Button.create{
					text = "Debug",
					actionPerformed = onDebugTap
				},
				Button.create{
					text = "Quit",
					actionPerformed = onQuitTap
				}
			}
		})
	else
		WindowManager.removeAllWindows()
	end
end

-- Close handler when the main pause window is closed
function onClose()
	Runtime:dispatchEvent{
		name = "gamePause",
		system = false,
		status = false
	}
end

-- Handler for the "Resume" button
--
-- Parameters:
--  button: The button pressed
function onResumeTap(button)
	WindowManager.removeTopWindow()
end

-- Handler for the "Restart" button
--
-- Parameters:
--  button: The button pressed
function onRestartTap(button)
	Runtime:dispatchEvent{
		name = "gameRestart"
	}
end

-- Handler for the "Debug" button
--
-- Parameters:
--  button: The button pressed
function onDebugTap(button)
	WindowManager.addWindow(MenuWindow.create{
		title = "Debug",
		buttons = {
			Button.create{
				text = "Only giants",
				actionPerformed = onDebugOnlyGiantsTap,
				selected = config.debug.onlyGiants
			},
			Button.create{
				text = "Fast zombies",
				actionPerformed = onDebugFastZombiesTap,
				selected = config.debug.fastZombies
			},
			Button.create{
				text = "Show collision masks",
				actionPerformed = onDebugCollisionMaskTap,
				selected = config.debug.showCollisionMask
			}
		}
	})
end

-- Handler for the "Quit" button
--
-- Parameters:
--  button: The button pressed
function onQuitTap(button)
	Runtime:dispatchEvent{
		name = "gameQuit"
	}
end

-- Handler for the "Only Giants" button of the debug menu
--
-- Parameters:
--  button: The button pressed
function onDebugOnlyGiantsTap(button)
	config.debug.onlyGiants = not config.debug.onlyGiants
	button:setSelected(not button.selected)
end

-- Handler for the "Fast Zombies" button of the debug menu
--
-- Parameters:
--  button: The button pressed
function onDebugFastZombiesTap(button)
	config.debug.fastZombies = not config.debug.fastZombies
	button:setSelected(not button.selected)
end

-- Handler for the "Show collision masks" button of the debug menu
--
-- Parameters:
--  button: The button pressed
function onDebugCollisionMaskTap(button)
	config.debug.showCollisionMask = not config.debug.showCollisionMask
	button:setSelected(not button.selected)
end

-----------------------------------------------------------------------------------------

return UpperBarPanel
