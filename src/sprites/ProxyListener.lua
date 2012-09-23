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
function ProxyListener.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, ProxyListener)

	return self
end

-- Destroy the sprite
function ProxyListener:destroy()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function ProxyListener:dispatch(event)
	event.target = self.target

	if type(self.listener) == "function" then
		self.listener(event)
	else
		self.listener[event.name](self.listener, event)
	end
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

function ProxyListener:sprite(event)
	self:dispatch(event)
end

function ProxyListener:tap(event)
	self:dispatch(event)
end

function ProxyListener:touch(event)
	self:dispatch(event)
end

-----------------------------------------------------------------------------------------

return ProxyListener
