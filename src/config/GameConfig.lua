config = {
	debug = {
		-- Speed
		fastMode = false,
		superFastMode = false,
		frameByFrame = false,

		-- Render
		showCollisionMask = false,
		soberZombies = false,

		-- Zombies
		oneCemetery = false,
		twoCemeteries = false,
		oneZombie = false,
		immediateSpawn = false,
		onlyGiants = false,
		randomGiants = false,

		-- Mana
		startWithMana = false,
		manaDropFury = false,
		noManaDrops = false,

		-- Values
		fastModeRatio = 3,
		superFastModeRatio = 8,
		startingMana = 200
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
		startingMana = 0,
		manaGenerationRate = 0.2,
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
			requiredInhabitants = 5
		},
		medium = {
			inhabitants = 0,
			spawnPeriod = 3500,
			maxInhabitants = 20,
			requiredInhabitants = 15
		},
		large = {
			inhabitants = 0,
			spawnPeriod = 2000,
			maxInhabitants = 30,
			requiredInhabitants = 25
		}
	},

	mana = {
		width = 64,
		height = 64,
		mask = {
			width = 10,
			height = 10,
			x = 25,
			y = 29
		},
		speed = 0.1,
		creation = {
			factor = 0.5,
			minTime = 6000,
			xoffset = 2
		},
		value = 10,
		maxDrops = 4
		-- easingTime = {
		-- 	reorganize = 1500,
		-- 	cancel = 750
		-- },
		-- skeleton = {
		-- 	nbZombies = 5
		-- },
		-- giant = {
		-- 	size = 6
		-- },
		-- tornado = {
		-- 	duration = 15000
		-- }
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
	}
}
