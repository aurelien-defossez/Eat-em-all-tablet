-----------------------------------------------------------------------------------------
--
-- Constants.lua
--
-- A list of constants used by more than one file.
-- These constants should not be used to store game values.
-- See GameConfig.lua for this matter.
--
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
		MANA = 5,
		WALL = 6
	}
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
