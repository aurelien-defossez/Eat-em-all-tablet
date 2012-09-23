-----------------------------------------------------------------------------------------
--
-- ProxyListener.lua
--
-----------------------------------------------------------------------------------------

module("ProxyListener", package.seeall)
ProxyListener.__index = ProxyListener

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the proxy listener
--
-- Parameters:
--  listener: The event listener
--  target: The event target (the event.target attribute when the event is dispatched)
function ProxyListener.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ProxyListener)

	return self
end

-- Destroy the proxy
function ProxyListener:destroy()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Dispatch the event to the real listener
--
-- Parameters:
--  event: The event to dispatch
function ProxyListener:dispatch(event)
	event.target = self.target

	-- Call the function directly or find the associate method if it is a table
	if type(self.listener) == "function" then
		self.listener(event)
	else
		self.listener[event.name](self.listener, event)
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Callback for the sprite event
--
-- Parameters:
--  event: The dispatched event
function ProxyListener:sprite(event)
	self:dispatch(event)
end

-- Callback for the tap event
--
-- Parameters:
--  event: The dispatched event
function ProxyListener:tap(event)
	self:dispatch(event)
end

-- Callback for the touch event
--
-- Parameters:
--  event: The dispatched event
function ProxyListener:touch(event)
	self:dispatch(event)
end

-----------------------------------------------------------------------------------------

return ProxyListener
