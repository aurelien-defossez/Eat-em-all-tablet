-----------------------------------------------------------------------------------------
--
-- Zombie.lua
--
-----------------------------------------------------------------------------------------

module("Zombie", package.seeall)

Zombie.__index = Zombie

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.utils.Utils")
require("src.utils.Constants")
require("src.config.GameConfig")

local SpriteManager = require("src.utils.SpriteManager")
local FiniteStateMachine = require("src.utils.FiniteStateMachine")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

DIRECTION_VECTOR = {
	UP = { x = 0, y = -1 },
	DOWN = { x = 0, y = 1 },
	LEFT = { x = -1, y = 0 },
	RIGHT = { x = 1, y = 0 }	
}

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

function initialize()
	classGroup = display.newGroup()
	spriteSet = SpriteManager.getSpriteSet(SPRITE_SET.ZOMBIE)

	-- Zombie state machine
	-- Full graph available in "doc/Zombie FSM.png"
	-- or https://raw.github.com/aurelien-defossez/Eat-em-all-tablet/master/doc/Zombie%20FSM.png
	STATES = {
		-- Spawning
		spawning = {
			name = "spawning",
			attributes = {
				animationName = "move",
				canAttack = false,
				isAttackable = false
			},
			transitions = {
				animationEnd = {
					state = "moving"
				}
			}
		},
		-- Moving
		moving = {
			name = "moving",
			attributes = {
				animationName = "move",
				canAttack = true,
				isAttackable = true,
				followSigns = true
			},
			onEnter = onEnterMove,
			transitions = {
				hitZombie = {
					state = "attackingZombie",
					onChange = onHitZombie
				},
				hitEnemyWall = {
					state = "attackingWall"
				},
				hitFriendlyWall = {
					onChange = onHitFriendlyWall
				},
				hitEnemyCemetery = {
					state = "attackingCemetery"
				},
				hitFriendlyCemetery = {
					onChange = onHitFriendlyWall
				},
				hitEnemyCity = {
					state = "attackingCity"
				},
				hitNeutralCity = {
					state = "enforcingCity",
					onChange = onHitNeutralCity
				},
				hitFriendlyCity = {
					state = "enforcingCity"
				},
				hitItem = {
					state = "positioningOnItem"
				},
				killed = {
					state = "goingToDie"
				}
			}
		},
		-- Attacking wall
		attackingWall = {
			name = "attackingWall",
			attributes = {
				animationName = "attack",
				canAttack = false,
				isAttackable = false
			},
			onEnter = onEnterAttackingWall,
			transitions = {
				animationEnd = {
					state = "dead"
				}
			}
		},
		-- Attacking cemetery
		attackingCemetery = {
			name = "attackingCemetery",
			attributes = {
				animationName = "attack",
				canAttack = false,
				isAttackable = false
			},
			onEnter = onEnterAttackingWall,
			transitions = {
				animationEnd = {
					state = "dead"
				}
			}
		},
		-- Attacking city
		attackingCity = {
			name = "attackingCity",
			attributes = {
				animationName = "attack",
				canAttack = false,
				isAttackable = false
			},
			onEnter = onEnterAttackingCity,
			transitions = {
				animationEnd = {
					state = "dead"
				}
			}
		},
		-- Enforce city
		enforcingCity = {
			name = "enforcingCity",
			attributes = {
				canAttack = false,
				isAttackable = false
			},
			onEnter = onEnterEnforcingCity,
			transitions = {
				animationEnd = {
					state = "dead"
				}
			}
		},
		-- Attacking zombie
		attackingZombie = {
			name = "attackingZombie",
			attributes = {
				animationName = "attack",
				canAttack = false,
				isAttackable = true
			},
			transitions = {
				animationEnd = {
					state = "moving"
				},
				killed = {
					state = "dying"
				}
			}
		},
		-- Positioning on item
		positioningOnItem = {
			name = "positioningOnItem",
			attributes = {
				canAttack = false,
				isAttackable = true,
				followSigns = false
			},
			onEnter = onEnterPositioningOnItem,
			transitions = {
				positioned = {
					state = "fetchingItem"
				},
				killed = {
					state = "dying",
					onChange = onItemDropped
				}
			}
		},
		-- Fetching item
		fetchingItem = {
			name = "fetchingItem",
			attributes = {
				animationName = "carry",
				canAttack = false,
				isAttackable = true,
				followSigns = false
			},
			onEnter = onEnterFetchingItem,
			transitions = {
				hitFriendlyWall = {
					state = "moving",
					onChange = onItemFetched
				},
				hitFriendlyCemetery = {
					state = "moving",
					onChange = onItemFetched
				},
				killed = {
					state = "dying",
					onChange = onItemDropped
				}
			}
		},
		-- Going to die
		goingToDie = {
			name = "goingToDie",
			attributes = {
				canAttack = true,
				isAttackable = false
			},
			transitions = {
				hitZombie = {
					onChange = onHitZombie
				},
				endOfFrame = {
					state = "dying"
				}
			}
		},
		-- Dying
		dying = {
			name = "dying",
			attributes = {
				animationName = "move",
				canAttack = false,
				isAttackable = false
			},
			onEnter = onEnterDying,
			transitions = {
				animationEnd = {
					state = "dead"
				}
			}
		},
		-- Dead
		dead = {
			name = "dead",
			attributes = {
				canAttack = false,
				isAttackable = false
			},
			onEnter = onEnterDead,
			transitions = {}
		}
	}
end

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

ctId = 1

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the zombie
--
-- Parameters:
--  tile: The tile the zombie spawned from
--  player: The zombie owner
--  grid: The grid
--  size: The zombie size
function Zombie.create(parameters)
	-- Create object
	local self = parameters or {}
	setmetatable(self, Zombie)

	-- Create group
	self.group = display.newGroup()
	classGroup:insert(self.group)

	-- Initialize attributes
	self.id = ctId
	self.width = config.zombie.width
	self.height = config.zombie.height
	self.x = self.tile.x
	self.y = self.tile.y
	self.direction = self.player.direction
	self.size = self.size or 1
	self.directionPriority = ZOMBIE.PRIORITY.NO_DIRECTION
	self.canAttack = false
	self.isAttackable = false
	self.followSigns = false
	self.animationName = nil
	self.stateMachine = FiniteStateMachine.create{
		states = STATES,
		initialState = "spawning",
		target = self
	}

	if self.size == 1 then
		self.isGiant = false
		self.speed = config.zombie.speed.normal
		self.hitPoints = config.zombie.hitPoints.normal
		self.strength = config.zombie.strength.normal
	else
		self.isGiant = true
		self.speed = config.zombie.speed.giant
		self.hitPoints = config.zombie.hitPoints.giant
		self.strength = config.zombie.strength.giant
	end

	ctId = ctId + 1

	-- Draw sprite
	self.zombieSprite = SpriteManager.newSprite(spriteSet)
	self.zombieSprite:addEventListener("sprite", self)

	self:changeDirection{
		direction = self.player.direction,
		priority = ZOMBIE.PRIORITY.DEFAULT
	}

	self:computeCollisionMask()

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Position sprite
	if not self.isGiant then
		if config.debug.soberZombies then
			self.zombieSprite.x = self.width / 2
			self.zombieSprite.y = self.height / 2
		else
			self.zombieSprite.x = self.width / 2 +
				math.random(config.zombie.randomOffsetRange.x[1], config.zombie.randomOffsetRange.x[2])
			self.zombieSprite.y = self.height / 2 +
				math.random(config.zombie.randomOffsetRange.y[1], config.zombie.randomOffsetRange.y[2])
		end
	else
		self.zombieSprite.xScale = 1.5
		self.zombieSprite.yScale = 1.5
		self.zombieSprite.x = 32
		self.zombieSprite.y = 20
	end

	-- Listen to events
	Runtime:addEventListener("spritePause", self)

	-- Add to group
	self.group:insert(self.zombieSprite)

	-- No spawning animation yet
	self.stateMachine:triggerEvent{
		event = "animationEnd"
	}

	return self
end

-- Destroy the zombie
function Zombie:destroy()
	Runtime:removeEventListener("spritePause", self)
	self.zombieSprite:removeEventListener("sprite", self)

	self.stateMachine:destroy()

	self.group:removeSelf()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Compute the zombie collision mask
function Zombie:computeCollisionMask()
	self.collisionMask = {
		x = self.x + config.zombie.mask.x,
		y = self.y + config.zombie.mask.y,
		width = config.zombie.mask.width,
		height = config.zombie.mask.height
	}
end

-- Move the zombie
--
-- Parameters:
--  x: X movement
--  y: Y movement
function Zombie:move(parameters)
	-- Update zombie position
	self.x = self.x + parameters.x
	self.y = self.y + parameters.y

	-- Determine tile collider
	local tileCollider = {
		x = self.x + self.width / 2,
		y = self.y + self.height / 2
	}

	-- Determine the tile the zombie is on and send events (enter, leave and reachCenter)
	if self.tile:isInside(tileCollider) then
		-- Staying on the same tile, checking if we passed through middle
		if self.directionVector.x ~= 0 then
			-- Middle is negative when going from right to left, to facilitate further calculations
			local middle = (self.tile.x + Tile.width_2) * self.directionVector.x

			if (tileCollider.x - parameters.x) * self.directionVector.x < middle
				and tileCollider.x * self.directionVector.x >= middle then
				self.tile:reachTileCenter(self)
			end
		else
			-- Middle is negative when going from bottom to up, to facilitate further calculations
			local middle = (self.tile.y + Tile.height_2) * self.directionVector.y

			if (tileCollider.y - parameters.y) * self.directionVector.y < middle
				and tileCollider.y * self.directionVector.y >= middle then
				self.tile:reachTileCenter(self)
			end
		end
	else
		-- Leave tile
		self.tile:leaveTile(self)

		self.directionPriority = ZOMBIE.PRIORITY.NO_DIRECTION

		-- Find new tile and enter it
		self.tile = self.grid:getTileByPixels(tileCollider)
		self.tile:enterTile(self)
	end

	-- In tile event
	self.tile:inTile(self)

	-- Correct trajectory
	if self.directionVector.x ~= 0 then
		if self.y > self.tile.y + 0.5 then
			self.y = self.y - 1
		elseif self.y < self.tile.y - 0.5 then
			self.y = self.y + 1
		end
	else
		if self.x > self.tile.x + 0.5 then
			self.x = self.x - 1
		elseif self.x < self.tile.x - 0.5 then
			self.x = self.x + 1
		end
	end

	-- Update collision mask
	self:computeCollisionMask()

	-- Move zombie sprite
	self.group.x = self.x
	self.group.y = self.y
end

-- Move the zombie to a certain position
--
-- Parameters:
--  x: The X position to move to
--  y: The Y position to move to
--  maxMovement: The maximal number of pixels to move from
function Zombie:moveTo(parameters)
	if self.x < parameters.x then
		self.x = math.min(self.x + parameters.maxMovement, parameters.x)
	elseif self.x > parameters.x then
		self.x = math.max(self.x - parameters.maxMovement, parameters.x)
	end

	if self.y < parameters.y then
		self.y = math.min(self.y + parameters.maxMovement, parameters.y)
	elseif self.y > parameters.y then
		self.y = math.max(self.y - parameters.maxMovement, parameters.y)
	end

	-- Move zombie sprite
	self.group.x = self.x
	self.group.y = self.y

	if self.x == parameters.x and self.y == parameters.y then
		self.stateMachine:triggerEvent{
			event = "positioned"
		}
	end
end

-- Changes the direction of the zombie
--
-- Parameters:
--  direction: The new direction
--  correctPosition: If true, then the position has to be corrected so the zombie stay on the tile center
--  priority: The direction priority, to prevent less priority directions to occur
--
-- Returns:
--  True if the zombie did follow the direction, false otherwise
function Zombie:changeDirection(parameters)
	if parameters.priority > self.directionPriority then
		self.direction = parameters.direction
		self.directionPriority = parameters.priority

		-- Update the direction vector
		if self.direction == DIRECTION.UP then
			self.directionVector = DIRECTION_VECTOR.UP
		elseif self.direction == DIRECTION.DOWN then
			self.directionVector = DIRECTION_VECTOR.DOWN
		elseif self.direction == DIRECTION.LEFT then
			self.directionVector = DIRECTION_VECTOR.LEFT
		elseif self.direction == DIRECTION.RIGHT then
			self.directionVector = DIRECTION_VECTOR.RIGHT
		end

		if parameters.correctPosition then
			-- Compute the offset between the zombie position and the tile center and correct the zombie position
			if self.direction == DIRECTION.UP or self.direction == DIRECTION.DOWN then
				local tileCenter = self.tile.x
				local centerOffset = math.abs(self.x - tileCenter)

				self.x = tileCenter
				self.y = self.y + centerOffset * self.directionVector.y
			else
				local tileCenter = self.tile.y
				local centerOffset = math.abs(self.y - tileCenter)

				self.y = tileCenter
				self.x = self.x + centerOffset * self.directionVector.x
			end
		end

		self:updateSprite()

		return true
	else
		return false
	end
end

-- Update the zombie sprite depending on the phase and the direction
function Zombie:updateSprite()
	local directionName

	-- Update the direction vector
	if self.direction == DIRECTION.UP then
		directionName = "up"
	elseif self.direction == DIRECTION.DOWN then
		directionName = "down"
	elseif self.direction == DIRECTION.LEFT then
		directionName = "left"
	elseif self.direction == DIRECTION.RIGHT then
		directionName = "right"
	end

	self.zombieSprite:prepare("zombie_" .. self.animationName .. "_" .. directionName .. "_" .. self.player.color.name)
	self.zombieSprite:play()
end

-- Hits the zombie. It does not actually kill it, if it can sustain the given damage.
--
-- Parameters
--  killer: The killer type, as possible Zombie constant types
--  hits: The number of hits the zombie takes (Default is all)
function Zombie:die(parameters)
	parameters.hits = parameters.hits or self.hitPoints
	self.hitPoints = self.hitPoints - parameters.hits

	if self.hitPoints <= 0 then
		self.stateMachine:triggerEvent{
			event = "killed"
		}
	end
end

-- Finalize the death of the zombie (for the transient goingToDie state)
function Zombie:leaveFrame()
	self.stateMachine:triggerEvent{
		event = "endOfFrame"
	}
end

-----------------------------------------------------------------------------------------
-- State machine listeners
-----------------------------------------------------------------------------------------

-- The onEnter callback for the "move" state
function Zombie:onEnterMove(parameters)
	self:updateSprite()
end

-- The onEnter callback for the "attackingWall" state
--
-- Parameters:
--  target: The wall
function Zombie:onEnterAttackingWall(parameters)
	parameters.target.player:addHPs(-self.strength)
	self:updateSprite()
end

-- The onChange callback for the "hitFriendlyWall" event
--
-- Parameters:
--  target: The wall
function Zombie:onHitFriendlyWall(parameters)
	-- Move backward
	self:changeDirection{
		direction = self.player.direction,
		priority = ZOMBIE.PRIORITY.DEFAULT
	}
end

-- The onEnter callback for the "attackingCity" state
--
-- Parameters:
--  target: The city
function Zombie:onEnterAttackingCity(parameters)
	parameters.target:attackCity(self)
	self:updateSprite()
end

-- The onChange callback for the "hitNeutralCity" event
--
-- Parameters:
--  target: The city
function Zombie:onHitNeutralCity(parameters)
	parameters.target:takeCity(self.player)
end

-- The onEnter callback for the "enforcingCity" state
--
-- Parameters:
--  target: The city
function Zombie:onEnterEnforcingCity(parameters)
	parameters.target:enforceCity(self)

	-- No enforcing animation yet
	self.stateMachine:triggerEvent{
		event = "animationEnd"
	}
end

-- The onEnter callback for the "positioningOnItem" state
--
-- Parameters:
--  target: The item
function Zombie:onEnterPositioningOnItem(parameters)
	self.item = parameters.target

	self:changeDirection{
		direction = getReverseDirection(self.player.direction),
		priority = ZOMBIE.PRIORITY.ITEM
	}

	self.item:attachZombie(self)
end

-- The onEnter callback for the "fetchingItem" state
function Zombie:onEnterFetchingItem(parameters)
	self.item:startMotion()

	self:changeDirection{
		direction = self.player.direction,
		priority = ZOMBIE.PRIORITY.ITEM
	}

	self:updateSprite()
end

-- The onChange callback for the "itemFetched" event
function Zombie:onItemFetched(parameters)
	self.item:fetched(self.player)
end

-- The onChange callback for the "itemDropped" event
--
-- Parameters:
--  target: The item
function Zombie:onItemDropped(parameters)
	self.item:detachZombie(self)
end

-- The onChange callback for the "hitZombie" event
--
-- Parameters:
--  target: The zombie
function Zombie:onHitZombie(parameters)
	parameters.target:die{
		killer = ZOMBIE.KILLER.ZOMBIE,
		hits = self.strength
	}

	self:updateSprite()
end

-- The onEnter callback for the "dying" state
function Zombie:onEnterDying(parameters)
	self.stateMachine:triggerEvent{
		event = "animationEnd"
	}
end

-- The onEnter callback for the "dead" state
function Zombie:onEnterDead(parameters)
	-- Remove zombie from the zombies list
	self.grid:removeZombie(self)

	-- Remove sprite from display
	self:destroy()
end

-----------------------------------------------------------------------------------------
-- Event listeners
-----------------------------------------------------------------------------------------

-- Enter frame handler
--
-- Parameters:
--  timeDelta: The time in ms since last frame
function Zombie:enterFrame(timeDelta)
	local state = self.stateMachine.currentState.name
	local speedFactor = Tile.width * timeDelta / 1000

	-- Move
	if state == "moving" then
		local movement = self.speed * speedFactor

		self:move{
			x = movement * self.directionVector.x,
			y = movement * self.directionVector.y
		}
	-- Get in position to fetch the item
	elseif state == "positioningOnItem" then
		local movement = self.speed * speedFactor
		local itemMask = self.item.collisionMask

		if self.player.direction == DIRECTION.RIGHT then
			self:moveTo{
				x = self.item.x - itemMask.width,
				y = self.item.y,
				maxMovement = movement
			}
		else
			self:moveTo{
				x = self.item.x + itemMask.width,
				y = self.item.y,
				maxMovement = movement
			}
		end
	-- Carry the item to the fortress
	elseif state == "fetchingItem" then
		local movement = self.item.speed * speedFactor

		self:move{
			x = movement,
			y = 0
		}
	end

	-- Draw collision mask
	if config.debug.showCollisionMask and not self.collisionMaskDebug then
		self.collisionMaskDebug = display.newRect(config.zombie.mask.x, config.zombie.mask.y,
			config.zombie.mask.width, config.zombie.mask.height)
		self.collisionMaskDebug.strokeWidth = 3
		self.collisionMaskDebug:setStrokeColor(255, 0, 0)
		self.collisionMaskDebug:setFillColor(0, 0, 0, 0)

		self.group:insert(self.collisionMaskDebug)
	end

	-- Remove collision mask
	if not config.debug.showCollisionMask and self.collisionMaskDebug then
		self.collisionMaskDebug:removeSelf()
		self.collisionMaskDebug = nil
	end
end


function Zombie:sprite(event)
	if event.phase == "end" then
		self.stateMachine:triggerEvent{
			event = "animationEnd"
		}
	end
end

-- Pause the sprite animation
-- Parameters:
--  event: The tile event, with these values:
--   status: If true, then pauses the animation, otherwise resumes it
function Zombie:spritePause(event)
	if event.status then
		self.zombieSprite:pause()
	else
		self.zombieSprite:play()
	end
end

-----------------------------------------------------------------------------------------

return Zombie
