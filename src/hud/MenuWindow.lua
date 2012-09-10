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
	self.width = config.windows.width
	self.height = 2 * config.windows.ypadding + config.windows.title.height +
		table.getn(self.buttons) * (config.windows.buttons.ypadding + config.windows.buttons.height)
	self.x = (config.screen.width - self.width) / 2
	self.y = (config.screen.height - self.height) / 2

	-- Draw background
	local background = display.newRect(0, 0, self.width, self.height)
	background.strokeWidth = 3
	background:setFillColor(204, 109, 0)
	background:setStrokeColor(135, 72, 0)
	
	-- Title
	local windowTitle = display.newText(self.title, 0, 0, native.systemFontBold, 30)
	windowTitle:setTextColor(255, 255, 255)
	windowTitle:setReferencePoint(display.CenterReferencePoint)
	windowTitle.x = self.width / 2
	windowTitle.y = config.windows.ypadding + config.windows.title.height / 2

	-- Add to group
	self.group:insert(background)
	self.group:insert(windowTitle)

	-- Position buttons
	local offset = config.windows.title.height + config.windows.ypadding + config.windows.buttons.ypadding
	for key, button in pairs(self.buttons) do
		button:moveTo{
			x = self.x + config.windows.xpadding,
			y = self.y + offset
		}

		offset = offset + config.windows.buttons.height + config.windows.buttons.ypadding
	end

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	return self
end

-- Destroy the panel
function MenuWindow:destroy()
	-- Destroy buttons
	for key, button in pairs(self.buttons) do
		button:destroy()
	end

	-- Remove display group
	self.group:removeSelf()

	-- Send close callback
	if self.onClose then
		self.onClose()
	end
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Show the window
function MenuWindow:show()
	self.group.isVisible = true

	-- Add button listeners
	for key, button in pairs(self.buttons) do
		button:show()
	end
end

-- Hide the window
function MenuWindow:hide()
	-- Remove button listeners
	for key, button in pairs(self.buttons) do
		button:hide()
	end

	self.group.isVisible = false
end

-----------------------------------------------------------------------------------------

return MenuWindow
