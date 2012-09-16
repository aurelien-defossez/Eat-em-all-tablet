config = {
	debug = {
		fastMode = false,
		superFastMode = false,
		oneCemetery = false,
		oneZombie = false,
		randomGiants = false,
		onlyGiants = false,
		immediateSpawn = false,
		fastItemSpawn = false,
		showCollisionMask = false,
		startWithItems = false,
		noItems = false,
		soberZombies = false,
		frameByFrame = false,

		fastModeRatio = 3,
		superFastModeRatio = 8
	},

	fps = 30,

	screen = {
		width = display.contentWidth,
		width_2 = display.contentWidth / 2,
		height = display.contentHeight,
		height_2 = display.contentHeight / 2
	},

	player = {
		hitPoints = 1000,
		maxSigns = 5,
		maxItems = 4,
		colors = {
			p1 = {
				r = 250,
				g = 64,
				b = 64
			},
			p2 = {
				r = 64,
				g = 96,
				b = 250
			}
		}
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
		-- easingTime = 1500,
		bars = {
			offset = {
				x = 50,
				y = 16
			},
			maxHeight = 50,
			width = 10
		},
		small = {
			inhabitants = 0,
			spawnPeriod = 5000,
			maxInhabitants = 10,
			exitPeriod = 400,
			requiredInhabitants = 5
		},
		medium = {
			inhabitants = 0,
			spawnPeriod = 3500,
			maxInhabitants = 20,
			exitPeriod = 300,
			requiredInhabitants = 15
		},
		large = {
			inhabitants = 0,
			spawnPeriod = 2000,
			maxInhabitants = 30,
			exitPeriod = 200,
			requiredInhabitants = 25
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
		speed = 0.1,
		creation = {
			factor = 0.5,
			minTime = 6000,
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
			size = 6
		},
		tornado = {
			duration = 15000
		}
	},

	fortressWall = {
		width = 64,
		height = 64
	},

	zombie = {
		width = 64,
		height = 64,
		hitPoints = {
			normal = 100,
			giant = 360
		},
		strength = {
			normal = 10,
			giant = 60
		},
		attackCooldown = {
			normal = 500,
			giant = 1000
		},
		mask = {
			width = 16,
			height = 50,
			x = 24,
			y = 7
		},
		-- In tiles per seconds
		speed = {
			normal = 0.25,
			giant = 0.1
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
				nbRows = 2,
				nbCols = 2
			},
			arrows = {
				width = 2 * 64,
				height = 4 * 64,
				counter = {
					xoffset = 15,
					yoffset = 10
				}
			}
			-- cities = {
			-- 	ypadding = 8,
			-- 	-- width = 2 Arrows width
			-- 	width = 2 * 64,
			-- 	-- height = maxHeight until bottom, less padding
			-- 	nbRows = 3,
			-- 	nbCols = 2
			-- }
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
			arrow_disabled_blue = {},
			arrow_disabled_red = {},
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
			item_tornado = {},
			item_giant = {},
			item_mine = {},
			item_skeleton = {}
		},
		tornado = {
			tornado = {
				frameCount = 4,
				period = 400
			}
		},
		mine = {
			mine_create = {
				frameCount = 14,
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
			zombie_move_right_red = {},
			zombie_move_left_red = {},
			zombie_move_up_red = {},
			zombie_move_down_red = {},
			zombie_carry_left_red = {},
			zombie_move_right_blue = {},
			zombie_move_left_blue = {},
			zombie_move_up_blue = {},
			zombie_move_down_blue = {},
			zombie_carry_right_blue = {}
		},
		misc = {
			pause = {}
		}
	}
}
