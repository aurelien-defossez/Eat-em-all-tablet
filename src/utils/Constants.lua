-----------------------------------------------------------------------------------------
--
-- Constants.lua
--
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Game constants
-----------------------------------------------------------------------------------------

DIRECTION = {
	UP = 0,
	DOWN = 180,
	RIGHT = 90,
	LEFT = 270,
	DELETE = 360
}

CITY = {
	SIZE = {
		SMALL = 1,
		MEDIUM = 2,
		LARGE = 3
	}
}

ITEM = {
	TYPE = {
		COUNT = 4,
		SKELETON = 1,
		GIANT = 2,
		FIRE = 3,
		MINE = 4
	}
}

TILE = {
	CONTENT = {
		CEMETERY = 1,
		CITY = 2,
		FORTRESS_WALL = 3,
		SIGN = 4
	}
}

ZOMBIE = {
	PHASE = {
		MOVE = 1,
		CARRY_ITEM_INIT = 2,
		CARRY_ITEM = 3,
		DEAD = 4
	},
	KILLER = {
		ZOMBIE = 1,
		FORTRESS = 2,
		CEMETERY = 3,
		CITY = 4,
		CITY_ENTER = 5
	}
}

-----------------------------------------------------------------------------------------
-- Utils constants
-----------------------------------------------------------------------------------------

SPRITE_SET = {
	ARROW = 1,
	CEMETERY = 2,
	CITY = 3,
	FORTRESS_WALL = 4,
	ITEM = 5,
	ZOMBIE = 6,
	MISC = 42
}

TABLE_LAYOUT = {
	DIRECTION = {
		LEFT_TO_RIGHT = 1,
		RIGHT_TO_LEFT = 2
	}
}

HIT_POINTS_PANEL = {
	DIRECTION = {
		LEFT_TO_RIGHT = 1,
		RIGHT_TO_LEFT = 2
	}
}
