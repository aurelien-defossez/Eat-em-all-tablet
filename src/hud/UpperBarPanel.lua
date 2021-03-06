-----------------------------------------------------------------------------------------
--
-- UpperBarPanel.lua
-- 
-- The upper bar panel, containing the HP bars and the menu.
--
-----------------------------------------------------------------------------------------

module("UpperBarPanel", package.seeall)
UpperBarPanel.__index = UpperBarPanel

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local SpriteManager = require("src.sprites.SpriteManager")
local MenuWindow = require("src.menu.MenuWindow")
local Button = require("src.menu.Button")
local WindowManager = require("src.menu.WindowManager")
local HitPointsPanel = require("src.hud.HitPointsPanel")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

-- Initialize the class
function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the upper bar panel
--
-- Parameters:
--  players: The two players
--  x: X position
--  y: Y position
--  width: The width
--  height: The height
function UpperBarPanel.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, UpperBarPanel)
	
	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.hpWidth = (self.width - hud.upperBar.menuButton.width) / 2

	self.hitPoints = {}
	self.hitPoints[1] = HitPointsPanel.create{
		maxHitPoints = self.players[1].hitPoints,
		hitPoints = self.players[1].hitPoints,
		x = self.x,
		y = self.y,
		width = self.hpWidth,
		direction = HIT_POINTS_PANEL.DIRECTION.FORWARD
	}

	self.hitPoints[2] = HitPointsPanel.create{
		maxHitPoints = self.players[2].hitPoints,
		hitPoints = self.players[2].hitPoints,
		x = self.x + self.hpWidth + hud.upperBar.menuButton.width,
		y = self.y,
		width = self.hpWidth,
		direction = HIT_POINTS_PANEL.DIRECTION.REVERSE
	}

	self.players[1].hitPointsPanel = self.hitPoints[1]
	self.players[2].hitPointsPanel = self.hitPoints[2]

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Create pause sprite
	self.pauseSprite = Sprite.create{
		spriteSet = SpriteManager.sets.misc,
		group = self.group,
		x = self.hpWidth + hud.upperBar.menuButton.width / 2,
		y = self.height / 2
	}

	-- Draw sprite
	self.pauseSprite:play("pause")

	-- Add listener on tap
	self.pauseSprite:addEventListener("tap", onPauseTap)

	return self
end

-- Destroy the panel
function UpperBarPanel:destroy()
	self.hitPoints[1]:destroy()
	self.hitPoints[2]:destroy()
	self.pauseSprite:destroy()
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
					text = "Debug",
					actionPerformed = onDebugTap
				},
				Button.create{
					text = "Restart",
					actionPerformed = onRestartTap
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

-- Handler for the "Back" button
--
-- Parameters:
--  button: The button pressed
function onBackTap(button)
	WindowManager.removeTopWindow()
end

-- Handler for the "Resume" button
--
-- Parameters:
--  button: The button pressed
function onResumeTap(button)
	WindowManager.removeAllWindows()
end

-- Handler for the "Restart" button
--
-- Parameters:
--  button: The button pressed
function onRestartTap(button)
	WindowManager.removeAllWindows()
	
	Runtime:dispatchEvent{
		name = "gameRestart"
	}
end

-- Handler for the "Quit" button
--
-- Parameters:
--  button: The button pressed
function onQuitTap(button)
	WindowManager.removeAllWindows()

	storyboard.gotoScene("src.scenes.Welcome")
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
				text = "Back",
				actionPerformed = onBackTap
			},
			Button.create{
				text = "Frame by frame mode",
				actionPerformed = onDebugFrameByFrameTap,
				selected = config.debug.frameByFrame
			},
			Button.create{
				text = "Fast mode",
				actionPerformed = onDebugFastModeTap,
				selected = config.debug.fastMode
			},
			Button.create{
				text = "Only giants",
				actionPerformed = onDebugOnlyGiantsTap,
				selected = config.debug.onlyGiants
			},
			Button.create{
				text = "Show collision masks",
				actionPerformed = onDebugCollisionMaskTap,
				selected = config.debug.showCollisionMask
			}
		}
	})
end

-- Handler for the "Frame by frame mode" button of the debug menu
--
-- Parameters:
--  button: The button pressed
function onDebugFrameByFrameTap(button)
	config.debug.frameByFrame = not config.debug.frameByFrame
	button:setSelected(not button.selected)
end

-- Handler for the "Fast mode" button of the debug menu
--
-- Parameters:
--  button: The button pressed
function onDebugFastModeTap(button)
	config.debug.fastMode = not config.debug.fastMode
	button:setSelected(not button.selected)

	if config.debug.fastMode then
		SpriteManager.setTimeScale(config.debug.fastModeRatio)
	else
		SpriteManager.setTimeScale(1)
	end
end

-- Handler for the "Only Giants" button of the debug menu
--
-- Parameters:
--  button: The button pressed
function onDebugOnlyGiantsTap(button)
	config.debug.onlyGiants = not config.debug.onlyGiants
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
