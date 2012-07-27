-----------------------------------------------------------------------------------------
--
-- EventManager.lua
--
-----------------------------------------------------------------------------------------

module("EventManager", package.seeall)

EventManager.__index = EventManager

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

group = nil

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Initializes the sprite manager
function initialize()
	group = display.newGroup()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Add a global event listener
--
-- Parameters:
--  eventName: The event name to listen to
--  callback: The method to call
function addListener(eventName, callback)
	group:addEventListener(eventName, callback)
end

-- Remove the listener
--
-- Parameters:
--  eventName: The event name listened
--  callback: The method called by this event
function removeListener(eventName, callback)
	group:removeEventListener(eventName, callback)
end

-- Dispatch an event
--
-- Parameters:
--  event: The event to throw, as an array with the field 'name' and any other user field
function dispatch(event)
	group:dispatchEvent(event)
end

-----------------------------------------------------------------------------------------

return EventManager
