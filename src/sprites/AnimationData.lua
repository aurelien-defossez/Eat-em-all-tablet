-----------------------------------------------------------------------------------------
--
-- AnimationData.lua
--
-- The definition of each set, within each the animations.
-- Each animation is defined by these attributes:
--  frameCount: The number of frames defining the animation (default is 1)
--				If frameCount > 1, then the source images should be suffixed by _01, _02
--				and so on
--				(e.g. zombie_attack_right_blue_01.png and zombie_attack_right_blue_02.png)
--  period: The period in ms to play the whole animation.
--			(Optional if there is only one frame)
--  loop: Tells whether the animation loops.
--		  (Default is true)
--
-----------------------------------------------------------------------------------------

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
	mana = {
		mana = {},
		mana_stack = {}
	},
	zombie = {
		zombie_spawn_red = {
			frameCount = 3,
			period = 200,
			loop = false
		},
		zombie_carry_red = {},
		zombie_move_right_red = {},
		zombie_move_left_red = {},
		zombie_move_up_red = {},
		zombie_move_down_red = {},
		zombie_attack_right_red = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_attack_left_red = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_attack_down_red = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_attack_up_red = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_die_red = {
			frameCount = 3,
			period = 200,
			loop = false
		},
		zombie_spawn_blue = {
			frameCount = 3,
			period = 200,
			loop = false
		},
		zombie_carry_blue = {},
		zombie_move_right_blue = {},
		zombie_move_left_blue = {},
		zombie_move_up_blue = {},
		zombie_move_down_blue = {},
		zombie_attack_right_blue = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_attack_left_blue = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_attack_down_blue = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_attack_up_blue = {
			frameCount = 2,
			period = 500,
			loop = false
		},
		zombie_die_blue = {
			frameCount = 3,
			period = 200,
			loop = false
		}
	},
	misc = {
		pause = {},
		upgrade = {}
	}
}
