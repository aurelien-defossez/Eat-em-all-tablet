module("GameConfig", package.seeall)

local City = require("City")

debug = {
	oneCemetery = false,
	oneZombie = false,
	randomGiants = false,
	immediateSpawn = true,
	immediateItemSpawn = false,
	showCollisionMask = false
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
	spawnPeriod = {
		normal = 3000,
		quick = 400
	}
}

city = {
	width = 64,
	height = 64,
	easingTime = 1500,
	inhabitantsText = {
		x = 24,
		y = 45
	},
	nameText = {
		x = 27,
		y = 27
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

item = {
	width = 64,
	height = 64,
	mask = {
		width = 32,
		height = 32,
		x = 16,
		y = 16
	},
	speed = {
		perZombie = 0.1,
		perGiant = 0.3,
		max = 1
	},
	creation = {
		time = {
			first = 10000,
			min = 5000,
			max = 20000,
		},
		xoffset = 2
	},
	easingTime = {
		reorganize = 1500,
		cancel = 750
	},
	skeleton = {
		nbZombies = 5
	},
	giant = {
		size = 8
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
		height = 50,
		x = 24,
		y = 7
	},
	-- speed in tiles per seconds
	speed = {
		normal = 0.5,
		giant = 0.2
	},
	tileColliderOffset = {
		x = 4,
		y = 0
	},
	randomOffsetRange = {
		x = { -10, 10 },
		y = { -12, 4 }
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
			width = 100,
			pause = {
				width = 32,
				height = 32
			}
		}
	},
	controls = {
		padding = 8,
		-- width = 2 x (arrow.width + padding)
		width = 2 * (arrow.width + 8),
		-- height = maxHeight - upperBar.height,
		items = {
			width = 2 * arrow.width,
			ypadding = 8,
			nbRows = 3,
			nbCols = 2
		},
		arrows = {
			width = 2 * arrow.width,
			height = 4 * arrow.height
		},
		cities = {
			ypadding = 8,
			-- width = 2 Arrows width
			width = 2 * arrow.width,
			-- height = maxHeight until bottom, less padding
			nbRows = 3,
			nbCols = 2
		}
	},
	grid = {
		nbRows = 10,
		nbCols = 11,
		xpadding = 6,
		lineWidth = 2
	}
}

sprites = {
	city = {
		city1_grey = {},
		city1_blue = {},
		city1_red = {},
		city2_grey = {},
		city2_blue = {},
		city2_red = {},
		city3_grey = {},
		city3_blue = {
			frameCount = 2,
			period = 1000
		},
		city3_red = {
			frameCount = 2,
			period = 1000
		}
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
			y = 3,
			size = City.SIZE_SMALL
		}, {
			x = 5,
			y = 8,
			size = City.SIZE_SMALL
		}, {
			x = 4,
			y = 7,
			size = City.SIZE_SMALL
		}, {
			x = 4,
			y = 6,
			size = City.SIZE_SMALL
		}, {
			x = 6,
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
