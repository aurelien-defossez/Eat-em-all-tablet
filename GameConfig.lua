module("GameConfig", package.seeall)

local City = require("City")

debug = {
	oneCemetery = false,
	oneZombie = false,
	immediateSpawn = true,
	showCollisionMask = false,
	showTileCollider = true
}

screen = {
	width = display.contentWidth,
	height = display.contentHeight
}

player = {
	hitPoints = 100
}

arrow = {
	width = 64,
	height = 64
}

cemetery = {
	width = 64,
	height = 64,
	spawnPeriod = 3000
}

city = {
	width = 64,
	height = 64,
	sizeText = {
		x = 28,
		y = 10,
	},
	inhabitantsText = {
		x = 24,
		y = 42
	},
	small = {
		inhabitants = 1,
		spawnPeriod = 5000,
		maxInhabitants = 50,
		exitPeriod = 400
	},
	medium = {
		inhabitants = 15,
		spawnPeriod = 3500,
		maxInhabitants = 75,
		exitPeriod = 300
	},
	large = {
		inhabitants = 40,
		spawnPeriod = 2000,
		maxInhabitants = 99,
		exitPeriod = 200
	}
}

fortressWall = {
	width = 64,
	height = 64
}

zombie = {
	width = 64,
	height = 64,
	mask = {
		width = 16,
		height = 50
	},
	-- speed in tiles per seconds
	speed = 1,
	tileColliderOffset = {
		x = 6,
		y = 0
	}
}

panels = {
	upperBar = {
		-- width = maxWidth
		height = 50,
		hitPoints = {
			-- width = (maxWidth - menuButton) / 2
			xpadding = 10,
			ypadding = 10
		},
		menuButton = {
			width = 100
		}
	},
	controls = {
		padding = 8,
		-- width = 2 x (arrow.width + padding)
		width = 2 * (arrow.width + 8),
		-- height = maxHeight - upperBar.height
		arrows = {
			width = 2 * arrow.width,
			height = 4 * arrow.height
		}
	},
	grid = {
		nbRows = 10,
		nbCols = 11,
		xpadding = 6,
		lineWidth = 2
	}
}

defaultMap = {
	cemeteries = {
		{
			x = 1,
			y = 3,
			playerId = 1
		}, {
			x = 1,
			y = 8,
			playerId = 1
		}, {
			x = 11,
			y = 3,
			playerId = 2
		}, {
			x = 11,
			y = 8,
			playerId = 2
		}
	},
	cities = {
		{
			x = 3,
			y = 2,
			size = City.SIZE_SMALL
		}, {
			x = 9,
			y = 9,
			size = City.SIZE_SMALL
		}, {
			x = 4,
			y = 6,
			size = City.SIZE_MEDIUM
		}, {
			x = 8,
			y = 5,
			size = City.SIZE_MEDIUM
		}, {
			x = 6,
			y = 4,
			size = City.SIZE_LARGE
		}
	}
}
