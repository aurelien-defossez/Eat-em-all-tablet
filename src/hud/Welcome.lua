-----------------------------------------------------------------------------------------
--
-- Welcome.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require("storyboard")
local Welcome = storyboard.newScene()

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local MenuWindow = require("src.hud.MenuWindow")
local Button = require("src.hud.Button")
local WindowManager = require("src.utils.WindowManager")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function Welcome:createScene(event)
	-- Do nothing
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function Welcome:destroyScene(event)
	-- Do nothing
end

-- Called immediately after scene has moved onscreen:
function Welcome:enterScene(event)
	-- Initialize managers
	SpriteManager.initialize()
	WindowManager.initialize()

	-- Initialize objects
	MenuWindow.initialize()
	Button.initialize()

	-- Create main window
	WindowManager.addWindow(MenuWindow.create{
		title = "Eat'em All!",
		buttons = {
			Button.create{
				text = "Start game",
				actionPerformed = onStartTap
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
end

-- Called when scene is about to move offscreen:
function Welcome:exitScene(event)

end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Handler for the "Back" button
--
-- Parameters:
--  button: The button pressed
function onBackTap(button)
	WindowManager.removeTopWindow()
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
				text = "Start with items",
				actionPerformed = onStartWithItemsTap,
				selected = config.debug.startWithItems
			},
			Button.create{
				text = "Fast mode",
				actionPerformed = onFastModeTap,
				selected = config.debug.fastMode
			},
			Button.create{
				text = "Random giants",
				actionPerformed = onRandomGiantsTap,
				selected = config.debug.randomGiants
			},
			Button.create{
				text = "Only Giants",
				actionPerformed = onOnlyGiantsTap,
				selected = config.debug.onlyGiants
			},
			Button.create{
				text = "Fast item spawn",
				actionPerformed = onFastItemSpawnTap,
				selected = config.debug.fastItemSpawn
			},
			Button.create{
				text = "One cemetery",
				actionPerformed = onOneCemeteryTap,
				selected = config.debug.oneCemetery
			},
			Button.create{
				text = "One zombie",
				actionPerformed = onOneZombieTap,
				selected = config.debug.oneZombie
			},
			Button.create{
				text = "Show collision masks",
				actionPerformed = onShowCollisionMaskTap,
				selected = config.debug.showCollisionMask
			},
			Button.create{
				text = "Frame by frame mode",
				actionPerformed = onFrameByFrameTap,
				selected = config.debug.frameByFrame
			}
		}
	})
end

-- Handler for the "Start with items" button
--
-- Parameters:
--  button: The button pressed
function onStartWithItemsTap(button)
	config.debug.startWithItems = not config.debug.startWithItems
	button:setSelected(not button.selected)
end

-- Handler for the "Fast mode" button
--
-- Parameters:
--  button: The button pressed
function onFastModeTap(button)
	config.debug.fastMode = not config.debug.fastMode
	button:setSelected(not button.selected)
end

-- Handler for the "Random giants" button
--
-- Parameters:
--  button: The button pressed
function onRandomGiantsTap(button)
	config.debug.randomGiants = not config.debug.randomGiants
	button:setSelected(not button.selected)
end

-- Handler for the "Only giants" button
--
-- Parameters:
--  button: The button pressed
function onOnlyGiantsTap(button)
	config.debug.onlyGiants = not config.debug.onlyGiants
	button:setSelected(not button.selected)
end

-- Handler for the "Fast item spawn" button
--
-- Parameters:
--  button: The button pressed
function onFastItemSpawnTap(button)
	config.debug.fastItemSpawn = not config.debug.fastItemSpawn
	button:setSelected(not button.selected)
end

-- Handler for the "One cemetery" button
--
-- Parameters:
--  button: The button pressed
function onOneCemeteryTap(button)
	config.debug.oneCemetery = not config.debug.oneCemetery
	button:setSelected(not button.selected)
end

-- Handler for the "One zombie" button
--
-- Parameters:
--  button: The button pressed
function onOneZombieTap(button)
	config.debug.oneZombie = not config.debug.oneZombie
	button:setSelected(not button.selected)
end

-- Handler for the "Show collision masks" button
--
-- Parameters:
--  button: The button pressed
function onShowCollisionMaskTap(button)
	config.debug.showCollisionMask = not config.debug.showCollisionMask
	button:setSelected(not button.selected)
end

-- Handler for the "Frame by frame mode" button
--
-- Parameters:
--  button: The button pressed
function onFrameByFrameTap(button)
	config.debug.frameByFrame = not config.debug.frameByFrame
	button:setSelected(not button.selected)
end

-- Handler for the "Start Game" button
--
-- Parameters:
--  button: The button pressed
function onStartTap(button)
	WindowManager.removeAllWindows()
	storyboard.gotoScene("src.game.Multiplayer")
end

-- Handler for the "Quit" button
--
-- Parameters:
--  button: The button pressed
function onQuitTap(button)
	os.exit()
end

-----------------------------------------------------------------------------------------
-- Binding
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
Welcome:addEventListener("createScene", Welcome)

-- "enterScene" event is dispatched whenever scene transition has finished
Welcome:addEventListener("enterScene", Welcome)

-- "exitScene" event is dispatched whenever before next scene's transition begins
Welcome:addEventListener("exitScene", Welcome)

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
Welcome:addEventListener("destroyScene", Welcome)


-----------------------------------------------------------------------------------------

return Welcome
