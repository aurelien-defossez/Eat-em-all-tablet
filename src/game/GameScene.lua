-----------------------------------------------------------------------------------------
--
-- GameScene.lua
--
-----------------------------------------------------------------------------------------

module("GameScene", package.seeall)

GameScene.__index = GameScene

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.jsonReader")
require("src.utils.Constants")
require("src.utils.Utils")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local UpperBarPanel = require("src.hud.UpperBarPanel")
local PlayerControlPanel = require("src.hud.PlayerControlPanel")
local ArrowsPanel = require("src.hud.ArrowsPanel")
local ItemsPanel = require("src.hud.ItemsPanel")
local CitiesPanel = require("src.hud.CitiesPanel")
local PlayerItem = require("src.hud.PlayerItem")
local Arrow = require("src.hud.Arrow")
local CityShortcut = require("src.hud.CityShortcut")
local Grid = require("src.game.Grid")
local Tile = require("src.game.Tile")
local Fire = require("src.game.Fire")
local Cemetery = require("src.game.Cemetery")
local FortressWall = require("src.game.FortressWall")
local Zombie = require("src.game.Zombie")
local Sign = require("src.game.Sign")
local City = require("src.game.City")
local MapItem = require("src.game.MapItem")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the grid
--
-- Parameters:
--  players: The two player objects
function GameScene.create(parameters)
	-- Create object
	self = parameters or {}
	setmetatable(self, GameScene)
	instance = self

	-- Initialize attributes
	self.paused = {
		system = false,
		user = false
	}

	-- Print debug messages
	printDebugMessages()

	-- Draw the background
	local background = display.newRect(0, 0, config.screen.width, config.screen.height)
	background:setFillColor(142, 57, 20)

	-- Initialize managers
	SpriteManager.initialize()

	-- Initialize groups in invert Z order
	UpperBarPanel.initialize()
	PlayerControlPanel.initialize()
	ArrowsPanel.initialize()
	ItemsPanel.initialize()
	CitiesPanel.initialize()
	Arrow.initialize()
	Tile.initialize()
	FortressWall.initialize()
	Cemetery.initialize()
	City.initialize()
	Sign.initialize()
	MapItem.initialize()
	Zombie.initialize()
	Fire.initialize()
	PlayerItem.initialize()
	CityShortcut.initialize()

	-- Listen to events
	Runtime:addEventListener("gamePause", self)

	-- Sizes
	local mainHeight = config.screen.height - config.panels.upperBar.height
	
	-- Create upper bar panel
	self.upperBar = UpperBarPanel.create{
		players = self.players
	}

	-- Create grid
	self.grid = Grid.create{
		players = self.players,
		x = config.panels.controls.width + config.panels.grid.xpadding,
		y = config.panels.upperBar.height,
		width = config.screen.width - 2 * config.panels.controls.width - 2 * config.panels.grid.xpadding,
		height = mainHeight
	}

	-- Load default map
	self.grid:loadMap(readJson("maps/map_test.json"))
	
	-- Create player control panels
	self.controlPanel1 = PlayerControlPanel.create{
		player = self.players[1],
		x = 0,
		y = config.panels.upperBar.height,
		height = mainHeight,
		grid = self.grid
	}

	self.controlPanel2 = PlayerControlPanel.create{
		player = self.players[2],
		x = config.screen.width - config.panels.controls.width,
		y = config.panels.upperBar.height,
		height = mainHeight,
		grid = self.grid
	}

	return self
end

-- Destroy the scene
function GameScene:destroy()
	self.controlPanel1:destroy()
	self.controlPanel2:destroy()
	self.grid:destroy()
	self.upperBar:destroy()

	Runtime:removeEventListener("gamePause", self)
end

-----------------------------------------------------------------------------------------
-- Methods - Game control
-----------------------------------------------------------------------------------------

-- Pause handler
--
-- Parameters:
--  event: The event object, with these data:
--   switch: If true, then switches the pause status
--   status: If true, then pauses the game, resumes otherwise (overriden by switch if true)
--   system: Tells whether the event is a system event
function GameScene:gamePause(event)
	if event.switch then
		if event.system then
			self.paused.system = not self.paused.system
		else
			self.paused.user = not self.paused.user
		end
	else
		-- Compare with true to force the boolean conversion
		if event.system then
			self.paused.system = (event.status == true)
		else
			self.paused.user = (event.status == true)
		end
	end
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function GameScene:enterFrame(timeDelta)
	if not self.paused.user and not self.paused.system then
		-- Relay event to grid
		self.grid:enterFrame(timeDelta)

		if config.debug.frameByFrame then
			self:pause{
				status = true,
				system = false
			}
		end
	end
end

-----------------------------------------------------------------------------------------

return GameScene
