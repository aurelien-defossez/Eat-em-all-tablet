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
local SpriteManager = require("SpriteManager")
local UpperBarPanel = require("UpperBarPanel")
local PlayerControlPanel = require("PlayerControlPanel")
local ArrowsPanel = require("ArrowsPanel")
local Arrow = require("Arrow")
local CityShortcut = require("CityShortcut")
local Grid = require("Grid")
local Tile = require("Tile")
local Cemetery = require("Cemetery")
local FortressWall = require("FortressWall")
local Zombie = require("Zombie")
local Sign = require("Sign")
local City = require("City")
local MapItem = require("MapItem")
local PlayerItem = require("PlayerItem")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the grid
--
-- Parameters:
--  players: The two player objects
function create(parameters)
	-- Create object
	self = parameters or {}
	setmetatable(self, GameScene)
	instance = self

	-- Initialize attributes
	self.paused = {
		system = false,
		user = false
	}

	-- Draw the background
	local background = display.newRect(0, 0, config.screen.width, config.screen.height)
	background:setFillColor(142, 57, 20)

	-- Initialize managers
	SpriteManager.initialize()

	-- Initialize groups in invert Z order
	UpperBarPanel.initialize()
	PlayerControlPanel.initialize()
	ArrowsPanel.initialize()
	Arrow.initialize()
	Tile.initialize()
	FortressWall.initialize()
	Cemetery.initialize()
	City.initialize()
	Sign.initialize()
	MapItem.initialize()
	Zombie.initialize()
	PlayerItem.initialize()
	CityShortcut.initialize()

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
	self.grid:loadMap(config.defaultMap)
	
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

	-- Draw
	self.upperBar:draw()
	self.controlPanel1:draw()
	self.controlPanel2:draw()
	self.grid:draw()

	return self
end

-- Destroy the scene
function destroy()
	self.controlPanel1:destroy()
	self.controlPanel2:destroy()
	self.grid:destroy()
	self.upperBar:destroy()
end

-----------------------------------------------------------------------------------------
-- Methods - Game control
-----------------------------------------------------------------------------------------

-- Pause the game
--
-- Parameters
--  system: True if the game has been paused by the system
function pause(parameters)
	parameters = parameters or {}

	if parameters.system then
		self.paused.system = true
	else
		self.paused.user = true
	end
end

-- Resume the game
--
-- Parameters
--  system: True if the game has been resumed by the system
function resume(parameters)
	parameters = parameters or {}

	if parameters.system then
		self.paused.system = false
	else
		self.paused.user = false
	end
end

-- Pause or resume the game depending on the current pause state
--
-- Parameters
--  system: True if the game has been paused or resumed by the system
function switchPause(parameters)
	parameters = parameters or {}

	if parameters.system then
		self.paused.system = not self.paused.system
	else
		self.paused.user = not self.paused.user
	end
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function enterFrame(timeDelta)
	if not self.paused.user and not self.paused.system then
		-- Relay event to grid
		self.grid:enterFrame(timeDelta)
	end
end

-----------------------------------------------------------------------------------------

return GameScene
