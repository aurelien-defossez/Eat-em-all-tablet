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

require("src.utils.Constants")
require("src.utils.Utils")
require("src.config.GameConfig")
require("src.config.Maps")

local SpriteManager = require("src.utils.SpriteManager")
local WindowManager = require("src.utils.WindowManager")
local UpperBarPanel = require("src.hud.UpperBarPanel")
local PlayerControlPanel = require("src.hud.PlayerControlPanel")
local ArrowsPanel = require("src.hud.ArrowsPanel")
local PowersPanel = require("src.hud.PowersPanel")
local PlayerItem = require("src.hud.PlayerItem")
local Arrow = require("src.hud.Arrow")
local MenuWindow = require("src.hud.MenuWindow")
local Button = require("src.hud.Button")
local Grid = require("src.game.Grid")
local Tile = require("src.game.Tile")
local Tornado = require("src.game.Tornado")
local Mine = require("src.game.Mine")
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

	-- Draw the background
	local background = display.newRect(0, 0, config.screen.width, config.screen.height)
	background:setFillColor(142, 57, 20)

	-- Initialize managers
	SpriteManager.initialize()
	WindowManager.initialize()

	-- Initialize groups in invert Z order
	UpperBarPanel.initialize()
	PlayerControlPanel.initialize()
	ArrowsPanel.initialize()
	PowersPanel.initialize()
	Arrow.initialize()
	Tile.initialize()
	FortressWall.initialize()
	Cemetery.initialize()
	City.initialize()
	Sign.initialize()
	MapItem.initialize()
	Zombie.initialize()
	Mine.initialize()
	Tornado.initialize()
	PlayerItem.initialize()
	MenuWindow.initialize()
	Button.initialize()

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
	self.grid:loadMap(maps.default)
	
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
end

-----------------------------------------------------------------------------------------
-- Event handlers
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function GameScene:enterFrame(timeDelta)
	-- Relay event to players
	for index, player in pairs(self.players) do
		player:enterFrame(timeDelta)
	end

		-- Relay event to grid
	self.grid:enterFrame(timeDelta)

	if config.debug.frameByFrame then
		Runtime:dispatchEvent{
			name = "gamePause",
			status = true,
			system = false
		}
	end
end

-----------------------------------------------------------------------------------------

return GameScene
