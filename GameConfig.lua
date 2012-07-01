module("GameConfig", package.seeall)

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
			height = 3 * arrow.height
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
	}
}
