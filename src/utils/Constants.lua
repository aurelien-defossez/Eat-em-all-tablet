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
	COUNT = 4,
	SKELETON = 1,
	GIANT = 2,
	TORNADO = 3,
	MINE = 4
}

TILE = {
	CONTENT = {
		CEMETERY = 1,
		CITY = 2,
		FORTRESS_WALL = 3,
		SIGN = 4,
		TORNADO = 5,
		MINE = 6
	},
	EVENT = {
		ENTER_TILE = "enterTile",
		LEAVE_TILE = "leaveTile",
		REACH_TILE_CENTER = "reachTileCenter",
		IN_TILE = "inTile"
	}
}

CONTENT_GROUP = {
	PRIMARY = {
		TILE.CONTENT.CEMETERY,
		TILE.CONTENT.CITY,
		TILE.CONTENT.FORTRESS_WALL,
		TILE.CONTENT.SIGN
	}
}

ZOMBIE = {
	KILLER = {
		ZOMBIE = 1,
		FORTRESS = 2,
		CEMETERY = 3,
		CITY = 4,
		CITY_ENTER = 5,
		TORNADO = 6,
		MINE = 7
	},
	PRIORITY = {
		NO_DIRECTION = 0,
		DEFAULT = 1,
		CITY = 2,
		SIGN = 3,
		TORNADO = 4,
		ITEM = 5,
		WALL = 6
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
	TORNADO = 7,
	MINE = 8,
	MANA = 9,
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
