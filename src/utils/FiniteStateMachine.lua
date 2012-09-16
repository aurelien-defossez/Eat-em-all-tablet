-----------------------------------------------------------------------------------------
--
-- FiniteStateMachine.lua
--
-----------------------------------------------------------------------------------------

module("FiniteStateMachine", package.seeall)

FiniteStateMachine.__index = FiniteStateMachine

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Creates a finite state machine
--
-- Parameters:
--  states: The list of states, with the key being the state name and these attributes:
--   name: The state name as a string (must be the same as the key)
--   attributes: A list of attributes to update when entering the state (optional)
--   onEnter: A callback called when entering the state (optional)
--   onLeave: A callbacl called when leaving the state (optional)
--   transitions: The list of transitions, with the key being the name of the event, and these attributes:
--    state: The new state of this transition (optional)
--    onChange: A callback called after the onEnter callback of the new state (optional)
--  initialState: The initial state
--  target: The object pointer (self), to be passed as first parameters for all callbacks
--
-- Example:
--	self.fsm = FiniteStateMachine.create{
-- 		states = {
-- 			A = {
-- 				name = "A",
-- 				attibutes = {
-- 					ploping = true
-- 				},
-- 				onEnter = onEnterA,
-- 				onLeave = onLeaveA,
-- 				transitions = {
-- 					x = {
-- 						state = B
-- 					},
-- 					y = {
-- 						state = B,
-- 						onChange = onChangeAy
-- 					},
-- 					z = {
-- 						onChange = onChangez
-- 					}
-- 				}
-- 			},
-- 			B = {
-- 				name = "B",
-- 				attibutes = {
-- 					ploping = false
-- 				},
-- 				onEnter = onEnterB,
-- 				transitions = {
-- 					y = {
-- 						state = A,
-- 					}
-- 				}
-- 			}
--		},
-- 		initialState = "A",
-- 		target = self,
--	}
function FiniteStateMachine.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, FiniteStateMachine)

	-- Initialize attributes
	self:changeState(parameters.initialState, parameters)

	return self
end

-- Destroy the FSM
function FiniteStateMachine:destroy()
	-- Do nothing
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Change the current state
--
-- Parameters:
--  stateName: The new state to go into
--  parameters: The event parameters, forwarded to the callbacks
--
-- Example:
--	self.fsm:changeState("B", {
--		plop = self.plop	
--	})
function FiniteStateMachine:changeState(stateName, parameters)
	local state = self.states[stateName]

	if not state then
		print("============================================================")
		print("ERROR: Cannot change state, target "..stateName.." undefined")
		print("============================================================")
	else
		-- Trigger onLeave callback
		if self.currentState and self.currentState.onLeave then
			self.currentState.onLeave(self.target, parameters)
		end

		-- print("Change state from "..(self.currentState and self.currentState.name or "<none>").." to "..stateName)
		self.currentState = state

		-- Set attributes
		if state.attributes then
			for key, value in pairs(state.attributes) do
				self.target[key] = value
			end
		end

		-- Trigger onEnter callback
		if state.onEnter then
			state.onEnter(self.target, parameters)
		end
	end
end

-- Trigger an event and changes the state if it corresponds to an entry in the machine
--
-- Parameters:
--  parameters: The event parameters to forward to the callback methods, with at least this attribute:
--   event: The event to trigger
-- Returns:
--  True if the event triggered a change of state, false otherwise
--
-- Example:
--	self.fsm:triggerEvent{
--		event = "x",
--		plop = self.plop
--	}
function FiniteStateMachine:triggerEvent(parameters)
	-- print("triggerEvent: "..parameters.event.." (state is "..(self.currentState and self.currentState.name or "<none>")..")")
	local transition = self.currentState.transitions[parameters.event]

	-- Make transition
	if transition then
		-- Change state
		if transition.state then
			self:changeState(transition.state, parameters)
		end

		-- Trigger onChange callback
		if transition.onChange then
			transition.onChange(self.target, parameters)
		end

		return true
	else
		return false
	end
end

-----------------------------------------------------------------------------------------

return FiniteStateMachine
