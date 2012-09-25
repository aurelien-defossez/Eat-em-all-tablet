-----------------------------------------------------------------------------------------
--
-- GameScene.lua
--
-- The game scene is the main game class.
-- It contains all entities, either graphical or non-graphical (e.g. the players).
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

local SpriteManager = require("src.sprites.SpriteManager")
local WindowManager = require("src.utils.WindowManager")
local UpperBarPanel = require("src.hud.UpperBarPanel")
local HitPointsPanel = require("src.hud.HitPointsPanel")
local PlayerControlPanel = require("src.hud.PlayerControlPanel")
local UpgradePanel = require("src.hud.UpgradePanel")
local ArrowsPanel = require("src.hud.ArrowsPanel")
local PowersPanel = require("src.hud.PowersPanel")
local Arrow = require("src.hud.Arrow")
local DraggedArrow = require("src.hud.DraggedArrow")
local MenuWindow = require("src.hud.MenuWindow")
local Button = require("src.hud.Button")
local Grid = require("src.game.Grid")
local Tile = require("src.game.Tile")
local Cemetery = require("src.game.Cemetery")
local FortressWall = require("src.game.FortressWall")
local Zombie = require("src.game.Zombie")
local Sign = require("src.game.Sign")
local City = require("src.game.City")
local ManaDrop = require("src.game.ManaDrop")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the grid
function GameScene.create(parameters)
	-- Create object
	self = parameters or {}
	setmetatable(self, GameScene)
	instance = self

	-- Initialize managers
	SpriteManager.initialize()
	WindowManager.initialize()

	-- Initialize sprite time scale
	if config.debug.superFastMode then
		SpriteManager.setTimeScale(config.debug.superFastModeRatio)
	elseif config.debug.fastMode then
		SpriteManager.setTimeScale(config.debug.fastModeRatio)
	end

	-- Draw the background
	self.background = display.newRect(0, 0, config.screen.width, config.screen.height)
	self.background:setFillColor(142, 57, 20)

	-- Initialize groups in invert Z order
	UpperBarPanel.initialize()
	HitPointsPanel.initialize()
	PlayerControlPanel.initialize()
	UpgradePanel.initialize()
	ArrowsPanel.initialize()
	PowersPanel.initialize()
	Arrow.initialize()
	Tile.initialize()
	FortressWall.initialize()
	Cemetery.initialize()
	City.initialize()
	Sign.initialize()
	ManaDrop.initialize()
	Zombie.initialize()
	DraggedArrow.initialize()
	MenuWindow.initialize()
	Button.initialize()

	-- Create players
	self.players = {}
	self.players[1] = Player.create{
		id = 1,
		color = {
			name = "red",
			r = config.player.colors.p1.r,
			g = config.player.colors.p1.g,
			b = config.player.colors.p1.b
		},
		direction = DIRECTION.RIGHT,
		tableLayoutDirection = TABLE_LAYOUT.DIRECTION.LEFT_TO_RIGHT,
		hitPoints = config.player.hitPoints
	}

	self.players[2] = Player.create{
		id = 2,
		color = {
			name = "blue",
			r = config.player.colors.p2.r,
			g = config.player.colors.p2.g,
			b = config.player.colors.p2.b
		},
		direction = DIRECTION.LEFT,
		tableLayoutDirection = TABLE_LAYOUT.DIRECTION.RIGHT_TO_LEFT,
		hitPoints = config.player.hitPoints
	}

	-- Create upper bar panel
	self.upperBar = UpperBarPanel.create{
		players = self.players,
		x = config.panels.controls.width + config.panels.grid.xpadding,
		y = 0,
		width = config.screen.width - 2 * config.panels.controls.width - 2 * config.panels.grid.xpadding,
		height = config.panels.upperBar.height
	}

	-- Create grid
	self.grid = Grid.create{
		players = self.players,
		x = config.panels.controls.width + config.panels.grid.xpadding,
		y = config.panels.upperBar.height,
		width = config.screen.width - 2 * config.panels.controls.width - 2 * config.panels.grid.xpadding,
		height = config.screen.height - config.panels.upperBar.height
	}

	-- Load default map
	self.grid:loadMap(maps.default)
	
	-- Create player control panels
	self.controlPanel1 = PlayerControlPanel.create{
		player = self.players[1],
		x = 0,
		y = 0,
		height = config.screen.height,
		grid = self.grid
	}

	self.controlPanel2 = PlayerControlPanel.create{
		player = self.players[2],
		x = config.screen.width - config.panels.controls.width,
		y = 0,
		height = config.screen.height,
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
	self.background:destroy()
	self.players[1]:destroy()
	self.players[2]:destroy()
end

-----------------------------------------------------------------------------------------
-- Event listeners
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

	-- Frame by Frame mode
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
