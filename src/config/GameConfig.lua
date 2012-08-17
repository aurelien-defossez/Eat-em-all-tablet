config = {
	debug = {
		fastMode = true,
		oneCemetery = false,
		oneZombie = false,
		randomGiants = false,
		onlyGiants = false,
		immediateSpawn = true,
		immediateItemSpawn = true,
		showCollisionMask = false,
		startWithItems = true,
		frameByFrame = false,

		fastModeRatio = 3
	},

	screen = {
		width = display.contentWidth,
		width_2 = display.contentWidth / 2,
		height = display.contentHeight,
		height_2 = display.contentHeight / 2
	},

	player = {
		hitPoints = 100
	},

	arrow = {
		width = 64,
		height = 64
	},

	cemetery = {
		width = 64,
		height = 64,
		spawnPeriod = {
			normal = 3000,
			quick = 400
		}
	},

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
	},

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
			perZombie = 0.05,
			max = 0.5
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
		},
		fire = {
			duration = 10000
		}
	},

	fortressWall = {
		width = 64,
		height = 64
	},

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
	},

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
					width = 46,
					height = 46
				}
			}
		},
		controls = {
			padding = 8,
			-- width = 2 x (arrow.width + padding)
			width = 2 * (64 + 8),
			-- height = maxHeight - upperBar.height,
			items = {
				width = 2 * 64,
				ypadding = 8,
				nbRows = 3,
				nbCols = 2
			},
			arrows = {
				width = 2 * 64,
				height = 4 * 64
			},
			cities = {
				ypadding = 8,
				-- width = 2 Arrows width
				width = 2 * 64,
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
	},

	sprites = {
		arrow = {
			arrow_blue = {},
			arrow_red = {},
			arrow_selected_blue = {},
			arrow_selected_red = {},
			arrow_crossed_blue = {},
			arrow_crossed_red = {}
		},
		cemetery = {
			cemetery_red = {},
			cemetery_blue = {}
		},
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
		},
		fortressWall = {
			fortress_wall_blue = {},
			fortress_wall_red = {}
		},
		item = {
			item = {},
			item_fire = {},
			item_giant = {},
			item_mine = {},
			item_skeleton = {}
		},
		fire = {
			fire = {
				frameCount = 3,
				period = 500
			}
		},
		mine = {
			mine_create = {
				frameCount = 15,
				period = 500,
				loop = false
			},
			mine_triggered = {
				frameCount = 6,
				period = 200,
				loop = false
			},
			mine_explode = {
				frameCount = 5,
				period = 800,
				loop = false
			}
		},
		zombie = {
			zombie_blue = {},
			zombie_red = {}
		},
		misc = {
			pause = {}
		}
	}
}
