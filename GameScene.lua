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

local config = require("GameConfig")
local Grid = require("Grid")
local Tile = require("Tile")
local PlayerControlPanel = require("PlayerControlPanel")
local Cemetery = require("Cemetery")
local FortressWall = require("FortressWall")
local Zombie = require("Zombie")
local Sign = require("Sign")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the grid
--
-- Parameters:
--  players: The two player objects
function GameScene.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, GameScene)

	-- Draw the background
	local background = display.newRect(0, 0, config.screen.width, config.screen.height)
	background:setFillColor(142, 57, 20)

	-- Initialize groups in invert Z order
	Tile.initialize()
	FortressWall.initialize()
	Cemetery.initialize()
	Sign.initialize()
	Zombie.initialize()

	-- Sizes
	local mainHeight = config.screen.height - config.panels.hitPoints.height

	-- Create grid
	self.grid = Grid.create{
		players = self.players,
		x = config.panels.controls.width + config.panels.grid.xpadding,
		y = config.panels.hitPoints.height,
		width = config.screen.width - 2 * config.panels.controls.width - 2 * config.panels.grid.xpadding,
		height = mainHeight
	}

	-- Load default map
	self.grid:loadMap(config.defaultMap)
	
	-- Create player control panels
	self.controlPanel1 = PlayerControlPanel.create{
		player = self.players[1],
		x = 0,
		y = config.panels.hitPoints.height,
		height = mainHeight,
		grid = self.grid
	}

	self.controlPanel2 = PlayerControlPanel.create{
		player = self.players[2],
		x = config.screen.width - config.panels.controls.width,
		y = config.panels.hitPoints.height,
		height = mainHeight,
		grid = self.grid
	}

	-- Draw
	self.controlPanel1:draw()
	self.controlPanel2:draw()
	self.grid:draw()

	return self
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function GameScene:enterFrame(timeDelta)
	-- Relay event to grid
	self.grid:enterFrame(timeDelta)
end

-----------------------------------------------------------------------------------------

return GameScene
