-----------------------------------------------------------------------------------------
--
-- HudConfig.lua
--
-- The HUD configuration values.
--
-----------------------------------------------------------------------------------------

hud = {
	upperBar = {
		-- width = maxWidth
		height = 50,
		hitPoints = {
			-- width = (maxWidth - menuButton) / 2
			xpadding = 4,
			ypadding = 10
		},
		menuButton = {
			width = 50,
			pause = {
				width = 46,
				height = 46
			}
		}
	},
	controls = {
		upgrade = {
			width = 2 * 64,
			height = 42,
			icon = {
				width = 20,
				height = 20
			}
		},
		arrows = {
			width = 2 * 64,
			height = 4 * 64,
			counter = {
				xoffset = 30,
				yoffset = -5
			}
		},
		padding = 8,
		-- width = 2 x (arrow.width + padding)
		width = 2 * (64 + 8),
		-- height = maxHeight - upperBar.height,
		powers = {
			width = 2 * 64,
			ypadding = 8,
			mana = {
				icon = {
					xoffset = 50,
					yoffset = 35
				},
				counter = {
					xoffset = 110,
					yoffset = 20
				}
			}
		}
	},
	grid = {
		nbRows = 10,
		nbCols = 11,
		xpadding = 6,
		lineWidth = 2
	},

	windows = {
		width = 400,
		xpadding = 20,
		ypadding = 20,
		title = {
			height = 30
		},
		buttons = {
			width = 360,
			height = 60,
			ypadding = 10
		}
	}
}
