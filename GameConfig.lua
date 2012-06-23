module("GameConfig", package.seeall)


screen = {
	width = display.contentWidth,
	height = display.contentHeight
}

arrow = {
	width = 64,
	height = 64
}

cemetery = {
	width = 64,
	height = 64
}

panels = {
	hitpoints = {
		height = 50
		-- width = max
	},
	controls = {
		padding = 8,
		-- width = 2 x (arrow.width + padding)
		width = 2 * (arrow.width + 8),
		-- height = max - hitpoints.height
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
	player1 = {
		cemeteries = {{
			x = 1,
			y = 3
		}, {
			x = 1,
			y = 8
		}}
	},
	player2 = {
		cemeteries = {{
			x = 11,
			y = 3
		}, {
			x = 11,
			y = 8
		}}
	}
}
