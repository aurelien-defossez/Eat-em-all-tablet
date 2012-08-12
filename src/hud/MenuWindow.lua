-----------------------------------------------------------------------------------------
--
-- MenuWindow.lua
--
-----------------------------------------------------------------------------------------

module("MenuWindow", package.seeall)

MenuWindow.__index = MenuWindow

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")
require("src.config.GameConfig")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create a window menu
--
-- Parameters:
--  buttons: The list of buttons to display
function MenuWindow.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, MenuWindow)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.width = 400
	self.height = 200
	self.x = (config.screen.width - self.width) / 2
	self.y = (config.screen.height - self.height) / 2

	-- Draw background
	local background = display.newRect(self.x, self.y, self.width, self.height)
	background.strokeWidth = 3
	background:setFillColor(204, 109, 0)
	background:setStrokeColor(135, 72, 0)
	
	-- Add background to group
	self.group:insert(background)

	-- Position buttons
	local offset = 10
	for key, button in pairs(self.buttons) do
		button:moveTo{
			x = self.x + 10,
			y = self.y + offset
		}

		offset = offset + 40
	end

	return self
end

-- Destroy the panel
function MenuWindow:destroy()
	for key, button in pairs(self.buttons) do
		button:destroy()
	end

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function MenuWindow:show()
	self.group.isVisible = true
end

function MenuWindow:hide()
	self.group.isVisible = false
end

-----------------------------------------------------------------------------------------

return MenuWindow
