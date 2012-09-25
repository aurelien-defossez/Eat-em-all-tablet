-----------------------------------------------------------------------------------------
--
-- Arrow.lua
--
-- An arrow from the player's arrow panel. It can be touched if it is enabled.
-- When touched, a DraggedArrow instance is created, which handle the drag'n'drop.
--
-----------------------------------------------------------------------------------------

module("Arrow", package.seeall)
Arrow.__index = Arrow

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.sprites.SpriteManager")
local Sprite = require("src.sprites.Sprite")
local DraggedArrow = require("src.hud.DraggedArrow")

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

-- Initialize the class
function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create a control arrow
--
-- Parameters:
--  player: The arrow owner
--  grid: The grid
--  direction: The arrow direction, using Direction constants
--  x: X position
--  y: Y position
function Arrow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Arrow)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.width = config.arrow.width
	self.height = config.arrow.height
	self.enabled = true

	-- Create sprite
	self.arrowSprite = Sprite.create{
		spriteSet = SpriteManager.sets.arrow,
		group = self.group,
		x = self.x or 0,
		y = self.height / 2 + (self.y or 0),
		orientation = self.direction or 0
	}

	-- Draw sprite
	self:updateSprite()

	-- Handle events
	self.arrowSprite:addEventListener("touch", self)

	return self
end

-- Destroy the arrow
function Arrow:destroy()
	self.arrowSprite:removeEventListener("touch", self)
	self.arrowSprite:destroy()
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Enable the dragging of the arrow
function Arrow:enable()
	self.enabled = true
	self:updateSprite()
end

-- Disable the dragging of the arrow
function Arrow:disable()
	self.enabled = false
	self:updateSprite()
end

-- Draw the sprite according to the arrow state
function Arrow:updateSprite()
	local animationName
	local disabled = self.enabled and "" or "disabled_"

	if self.direction ~= DIRECTION.DELETE then
		animationName = "arrow_" .. disabled .. self.player.color.name
	else 
		animationName = "arrow_crossed_" .. self.player.color.name
	end

	self.arrowSprite:play(animationName)
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Touch handler on one of the four arrows of the control panel
--
-- Parameters:
--  event: The touch event
function Arrow:touch(event)
	-- Begin drag by creating a new draggable arrow
	if self.enabled and event.phase == "began" then
		DraggedArrow.create{
			x = event.x,
			y = event.y,
			direction = self.direction,
			player = self.player,
			grid = self.grid
		}
	end

	return true
end

-----------------------------------------------------------------------------------------

return Arrow
