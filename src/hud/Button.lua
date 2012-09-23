-----------------------------------------------------------------------------------------
--
-- Button.lua
--
-----------------------------------------------------------------------------------------

module("Button", package.seeall)

Button.__index = Button

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Constants")

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create a button
--
-- Parameters:
--  text: The text to display
--  actionPerformed: The action performed when the button is tapped
--  selected: Tells whether the button is selected
function Button.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Button)
	
	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)
	
	-- Initialize attributes
	self.x = self.x or 0
	self.y = self.y or 0
	self.height = config.windows.buttons.height
	self.width = config.windows.buttons.width
	self.selected = self.selected or false

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Draw background
	self.background = display.newRect(self.x, self.y, self.width, self.height)
	self.background.strokeWidth = 3

	-- Text
	self.buttonText = display.newText(self.text, 0, 0, native.systemFontBold, 24)
	self.buttonText:setTextColor(255, 255, 255)
	self.buttonText:setReferencePoint(display.CenterReferencePoint)
	self.buttonText.x = self.width / 2
	self.buttonText.y = self.height / 2

	-- Set color depending on state
	self:setSelected(self.selected)

	-- Bind events
	self.background:addEventListener("tap", self)
	
	-- Add to group
	self.group:insert(self.background)
	self.group:insert(self.buttonText)
	
	return self
end

-- Destroy the button
function Button:destroy()
	self.background:removeEventListener("tap", self)
	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Show the button
function Button:show()
	self.group.isVisible = true
end

-- Hide the button
function Button:hide()
	self.group.isVisible = false
end

-- Move the button
--
-- Parameters:
--  x: The X position
--  y: The Y position
function Button:moveTo(parameters)
	self.x = parameters.x
	self.y = parameters.y

	self.group.x = self.x
	self.group.y = self.y
end

-- Sets the button state, thus changing its appearance
--
-- Parameters:
--  selected: True if the button is selected
function Button:setSelected(selected)
	self.selected = selected

	if self.selected then
		self.background:setFillColor(180, 68, 0)
		self.background:setStrokeColor(255, 180, 40)
	else
		self.background:setFillColor(136, 52, 0)
		self.background:setStrokeColor(230, 150, 20)
	end
end

-----------------------------------------------------------------------------------------
-- Callbacks
-----------------------------------------------------------------------------------------

-- Tap handler on the button
--
-- Parameters:
--  evemt: The event thrown
function Button:tap(event)
	self.actionPerformed(self)

	return true
end

-----------------------------------------------------------------------------------------

return Button
