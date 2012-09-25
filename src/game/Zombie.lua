-----------------------------------------------------------------------------------------
--
-- Zombie.lua
--
-- A zombie is the main unit of the game. It belongs to a player and it pretty stupid.
-- It goes always in one direction, changes direction if it hits something or if a
-- player's sign redirects it.
-- When it hits a city, it either attacks it or enforce it.
-- When it hits an enemy cemetery or fortress wall, it attacks it and the opponent loses
-- 1 HP.
-- When it hits a friendly cemetery or fortress wall, the zombie goes back.
-- When it hits another zombie, it starts to attack it.
-- When it hits a mana drop not yet carried, it goes to fetch it to the player fortress.
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

local SpriteManager = require("src.sprites.SpriteManager")
local Sprite = require("src.sprites.Sprite")
local FiniteStateMachine = require("src.utils.FiniteStateMachine")
local Tile = require("src.game.Tile")

-----------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------

-- The direction vectors
DIRECTION_VECTOR = {
	UP = { x = 0, y = -1 },
	DOWN = { x = 0, y = 1 },
	LEFT = { x = -1, y = 0 },
	RIGHT = { x = 1, y = 0 }	
}

-----------------------------------------------------------------------------------------
-- Class initialization
-----------------------------------------------------------------------------------------

-- Initialize the class
function initialize()
	classGroup = display.newGroup()

	-- Zombie state machine
	-- Full graph available in "doc/Zombie FSM.png"
	-- or https://raw.github.com/aurelien-defossez/Eat-em-all-tablet/master/doc/Zombie%20FSM.png
	STATES = {
		-- Spawning
		spawning = {
			name = "spawning",
			attributes = {
				animationName = "spawn",
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
				hitMana = {
					state = "positioningOnMana"
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
		-- Positioning on mana drop
		positioningOnMana = {
			name = "positioningOnMana",
			attributes = {
				canAttack = false,
				isAttackable = true,
				followSigns = false
			},
			onEnter = onEnterPositioningOnMana,
			transitions = {
				positioned = {
					state = "fetchingMana"
				},
				killed = {
					state = "dying",
					onChange = onManaDropped
				}
			}
		},
		-- Fetching mana drop
		fetchingMana = {
			name = "fetchingMana",
			attributes = {
				animationName = "carry",
				canAttack = false,
				isAttackable = true,
				followSigns = false
			},
			onEnter = onEnterFetchingMana,
			transitions = {
				hitFriendlyWall = {
					state = "moving",
					onChange = onManaFetched
				},
				hitFriendlyCemetery = {
					state = "moving",
					onChange = onManaFetched
				},
				killed = {
					state = "dying",
					onChange = onManaDropped
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
				animationName = "die",
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

	self:computeCollisionMask()

	-- Update class attributes
	ctId = ctId + 1

	-- Position group
	self.group.x = self.x
	self.group.y = self.y

	-- Position sprite representation (not the actual object)
	local representation = {
		x = self.width / 2,
		y = self.height / 2,
		scale = 1
	}

	if self.isGiant then
		representation.x = 32
		representation.y = 20
		representation.scale = 1.5
	elseif not config.debug.soberZombies then
		local range = config.zombie.randomOffsetRange
		representation.x = self.width / 2 + math.random(range.x[1], range.x[2])
		representation.y = self.height / 2 + math.random(range.y[1], range.y[2])
	end

	-- Create sprite
	self.zombieSprite = Sprite.create{
		spriteSet = SpriteManager.sets.zombie,
		group = self.group,
		x = representation.x,
		y = representation.y,
		scale = representation.scale
	}

	-- Add sprite event listener
	self.zombieSprite:addEventListener("sprite", self)

	-- Set initial direction
	self:changeDirection{
		direction = self.player.direction,
		priority = ZOMBIE.PRIORITY.DEFAULT
	}

	return self
end

-- Destroy the zombie
function Zombie:destroy()
	self.zombieSprite:removeEventListener("sprite", self)
	self.zombieSprite:destroy()
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
	local completeAnimationName

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

	if self.animationName == "carry" or self.animationName == "spawn" or self.animationName == "die" then
		completeAnimationName = "zombie_" .. self.animationName .. "_" .. self.player.color.name
	else
		completeAnimationName = "zombie_" .. self.animationName .. "_" .. directionName .. "_" .. self.player.color.name
	end

	self.zombieSprite:play(completeAnimationName)
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

		return true
	else
		return false
	end
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

-- The onEnter callback for the "positioningOnMana" state
--
-- Parameters:
--  target: The mana drop
function Zombie:onEnterPositioningOnMana(parameters)
	self.mana = parameters.target

	self:changeDirection{
		direction = getReverseDirection(self.player.direction),
		priority = ZOMBIE.PRIORITY.MANA
	}

	self.mana:attachZombie(self)
end

-- The onEnter callback for the "fetchingMana" state
function Zombie:onEnterFetchingMana(parameters)
	self.mana:startMotion()

	self:changeDirection{
		direction = self.player.direction,
		priority = ZOMBIE.PRIORITY.MANA
	}

	self:updateSprite()
end

-- The onChange callback for the "manaFetched" event
function Zombie:onManaFetched(parameters)
	self.mana:fetched(self.player)
end

-- The onChange callback for the "manaDropped" event
--
-- Parameters:
--  target: The mana
function Zombie:onManaDropped(parameters)
	self.mana:detachZombie(self)
end

-- The onChange callback for the "hitZombie" event
--
-- Parameters:
--  target: The zombie
function Zombie:onHitZombie(parameters)
	local dead = parameters.target:die{
		killer = ZOMBIE.KILLER.ZOMBIE,
		hits = self.strength
	}

	if dead then
		self.player:addXp(1)
	end

	self:updateSprite()
end

-- The onEnter callback for the "dying" state
function Zombie:onEnterDying(parameters)
	self:updateSprite()
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
	-- Get in position to fetch the mana drop
	elseif state == "positioningOnMana" then
		local movement = self.speed * speedFactor
		local manaMask = self.mana.collisionMask

		if self.player.direction == DIRECTION.RIGHT then
			self:moveTo{
				x = self.mana.x - manaMask.width,
				y = self.mana.y,
				maxMovement = movement
			}
		else
			self:moveTo{
				x = self.mana.x + manaMask.width,
				y = self.mana.y,
				maxMovement = movement
			}
		end
	-- Carry the mana drop to the fortress
	elseif state == "fetchingMana" then
		local movement = self.mana.speed * speedFactor

		self:move{
			x = movement,
			y = 0
		}
	end

	-- Draw collision mask
	if config.debug.showCollisionMask and not self.collisionMaskDebug then
		self.collisionMaskDebug = display.newRect(config.zombie.mask.x, config.zombie.mask.y,
			config.zombie.mask.width, config.zombie.mask.height)
		self.collisionMaskDebug.strokeWidth = 1
		self.collisionMaskDebug:setStrokeColor(255, 0, 0)
		self.collisionMaskDebug:setFillColor(0, 0, 0, 0)

		self.group:insert(self.collisionMaskDebug)
	end

	-- Remove collision mask
	if not config.debug.showCollisionMask and self.collisionMaskDebug then
		self.collisionMaskDebug:removeSelf()
		self.collisionMaskDebug = nil
	end

	self.stateMachine:triggerEvent{
		event = "endOfFrame"
	}
end

-- Sprite event handler
--
-- Parameters:
--  event: The event thrown
function Zombie:sprite(event)
	if event.phase == "end" then
		self.stateMachine:triggerEvent{
			event = "animationEnd"
		}
	end
end

-----------------------------------------------------------------------------------------

return Zombie
