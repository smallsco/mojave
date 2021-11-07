local CustomGameDefinitions = {}

-- This table defines the starting parameters for select custom games, that were shown on SPL.
local definitions = {

    -- 19x10 vertical food line, https://www.youtube.com/watch?v=FB2wkxndeog&t=1282s
    {
        name = "19x10 Vertical Food Line",
        definition = {
            width = 19,
            height = 10,
            food_spawns = {
                {x=9, y=0, turn=0},{x=9, y=1, turn=0},{x=9, y=2, turn=0},{x=9, y=3, turn=0},{x=9, y=4, turn=0},
                {x=9, y=5, turn=0},{x=9, y=6, turn=0},{x=9, y=7, turn=0},{x=9, y=8, turn=0},{x=9, y=9, turn=0}
            },
            hazard_spawns = {},
            start_positions = {
                {x=1, y=8}, {x=17, y=8}, {x=1, y=6}, {x=17, y=6}, {x=1, y=4}, {x=17, y=4}, {x=1, y=2}, {x=17, y=2}
            },
        }
    },

    -- 19x19 bridges, https://www.youtube.com/watch?v=FB2wkxndeog&t=1643s
    {
        name = "19x19 Bridges",
        definition = {
            width = 19,
            height = 19,
            food_spawns = {
                {x=9, y=3, turn=0}, {x=9, y=15, turn=0}, {x=7, y=7, turn=0}, {x=11, y=7, turn=0}, {x=7, y=11, turn=0},
                {x=11, y=11, turn=0}, {x=4, y=9, turn=0}, {x=14, y=9, turn=0}
            },
            hazard_spawns = {
                {x=9, y=0, turn=0}, {x=9, y=1, turn=0}, {x=9, y=2, turn=0}, {x=9, y=4, turn=0}, {x=9, y=5, turn=0},
                {x=9, y=6, turn=0}, {x=9, y=7, turn=0}, {x=9, y=8, turn=0}, {x=9, y=9, turn=0}, {x=9, y=10, turn=0},
                {x=9, y=11, turn=0}, {x=9, y=12, turn=0}, {x=9, y=13, turn=0}, {x=9, y=14, turn=0}, {x=9, y=16, turn=0},
                {x=9, y=17, turn=0}, {x=9, y=18, turn=0}, {x=0, y=9, turn=0}, {x=1, y=9, turn=0}, {x=2, y=9, turn=0},
                {x=3, y=9, turn=0}, {x=5, y=9, turn=0}, {x=6, y=9, turn=0}, {x=7, y=9, turn=0}, {x=8, y=9, turn=0},
                {x=10, y=9, turn=0}, {x=11, y=9, turn=0}, {x=12, y=9, turn=0}, {x=13, y=9, turn=0}, {x=15, y=9, turn=0},
                {x=16, y=9, turn=0}, {x=17, y=9, turn=0}, {x=18, y=9, turn=0}, {x=8, y=8, turn=0}, {x=8, y=10, turn=0},
                {x=10, y=8, turn=0}, {x=10, y=10, turn=0}
            },
            start_positions = {
                {x=1, y=1}, {x=17, y=17}, {x=1, y=17}, {x=17, y=1}, {x=5, y=1}, {x=13, y=17}, {x=5, y=17}, {x=13, y=1},
                {x=1, y=5}, {x=17, y=13}, {x=1, y=13}, {x=17, y=5}, {x=5, y=5}, {x=13, y=13}, {x=5, y=13}, {x=13, y=5}
            }
        }
    },

    -- 25x25 two vertical food lines, https://www.youtube.com/watch?v=FB2wkxndeog&t=2024s
    {
        name = "25x25 Two Vertical Food Lines",
        definition = {
            width = 25,
            height = 25,
            food_spawns = {
                {x=11, y=0, turn=0}, {x=11, y=1, turn=0}, {x=11, y=2, turn=0}, {x=11, y=3, turn=0}, {x=11, y=4, turn=0},
                {x=11, y=5, turn=0}, {x=11, y=6, turn=0}, {x=11, y=7, turn=0}, {x=11, y=8, turn=0}, {x=11, y=9, turn=0},
                {x=11, y=10, turn=0}, {x=11, y=11, turn=0}, {x=11, y=12, turn=0}, {x=11, y=13, turn=0},
                {x=11, y=14, turn=0}, {x=11, y=15, turn=0}, {x=11, y=16, turn=0}, {x=11, y=17, turn=0},
                {x=11, y=18, turn=0}, {x=11, y=19, turn=0}, {x=11, y=20, turn=0}, {x=11, y=21, turn=0},
                {x=11, y=22, turn=0}, {x=11, y=23, turn=0}, {x=11, y=24, turn=0}, {x=13, y=0, turn=0},
                {x=13, y=1, turn=0}, {x=13, y=2, turn=0}, {x=13, y=3, turn=0}, {x=13, y=4, turn=0}, {x=13, y=5, turn=0},
                {x=13, y=6, turn=0}, {x=13, y=7, turn=0}, {x=13, y=8, turn=0}, {x=13, y=9, turn=0},
                {x=13, y=10, turn=0}, {x=13, y=11, turn=0}, {x=13, y=12, turn=0}, {x=13, y=13, turn=0},
                {x=13, y=14, turn=0}, {x=13, y=15, turn=0}, {x=13, y=16, turn=0}, {x=13, y=17, turn=0},
                {x=13, y=18, turn=0}, {x=13, y=19, turn=0}, {x=13, y=20, turn=0}, {x=13, y=21, turn=0},
                {x=13, y=22, turn=0}, {x=13, y=23, turn=0}, {x=13, y=24, turn=0}
            },
            hazard_spawns = {},
            start_positions = {
                {x=1, y=1}, {x=23, y=23}, {x=1, y=23}, {x=23, y=1}, {x=1, y=5}, {x=23, y=19}, {x=1, y=19}, {x=23, y=5},
                {x=1, y=11}, {x=23, y=15}, {x=1, y=15}, {x=23, y=11}
            }
        }
    },

    -- 11x11 rings, https://www.youtube.com/watch?v=FB2wkxndeog&t=2277s
    {
        name = "11x11 Rings",
        definition = {
            width = 11,
            height = 11,
            food_spawns = {},
            hazard_spawns = {
                {x=1, y=1, turn=0}, {x=2, y=1, turn=0}, {x=3, y=1, turn=0}, {x=4, y=1, turn=0}, {x=5, y=1, turn=0},
                {x=6, y=1, turn=0}, {x=7, y=1, turn=0}, {x=8, y=1, turn=0}, {x=9, y=1, turn=0}, {x=9, y=2, turn=0},
                {x=9, y=3, turn=0}, {x=9, y=4, turn=0}, {x=9, y=5, turn=0}, {x=9, y=6, turn=0}, {x=9, y=7, turn=0},
                {x=9, y=8, turn=0}, {x=9, y=9, turn=0}, {x=8, y=9, turn=0}, {x=7, y=9, turn=0}, {x=6, y=9, turn=0},
                {x=5, y=9, turn=0}, {x=4, y=9, turn=0}, {x=3, y=9, turn=0}, {x=2, y=9, turn=0}, {x=1, y=9, turn=0},
                {x=1, y=8, turn=0}, {x=1, y=7, turn=0}, {x=1, y=6, turn=0}, {x=1, y=5, turn=0}, {x=1, y=4, turn=0},
                {x=1, y=3, turn=0}, {x=1, y=2, turn=0}, {x=3, y=3, turn=0}, {x=4, y=3, turn=0}, {x=5, y=3, turn=0},
                {x=6, y=3, turn=0}, {x=7, y=3, turn=0}, {x=7, y=4, turn=0}, {x=7, y=5, turn=0}, {x=7, y=6, turn=0},
                {x=7, y=7, turn=0}, {x=6, y=7, turn=0}, {x=5, y=7, turn=0}, {x=4, y=7, turn=0}, {x=3, y=7, turn=0},
                {x=3, y=6, turn=0}, {x=3, y=5, turn=0}, {x=3, y=4, turn=0}
            },
            start_positions = {}
        }
    },

    -- 25x25 bridges, https://www.youtube.com/watch?v=FB2wkxndeog&t=2494s
    {
        name = "25x25 Bridges",
        definition = {
            width = 25,
            height = 25,
            food_spawns = {
                {x=12, y=1, turn=0}, {x=12, y=7, turn=0}, {x=12, y=17, turn=0}, {x=12, y=23, turn=0},
                {x=1, y=12, turn=0}, {x=7, y=12, turn=0}, {x=17, y=12, turn=0}, {x=23, y=12, turn=0}
            },
            hazard_spawns = {
                {x=12, y=0, turn=0}, {x=12, y=2, turn=0}, {x=12, y=3, turn=0}, {x=12, y=4, turn=0}, {x=12, y=5, turn=0},
                {x=12, y=6, turn=0}, {x=12, y=8, turn=0}, {x=12, y=9, turn=0}, {x=12, y=10, turn=0},
                {x=12, y=11, turn=0}, {x=12, y=12, turn=0}, {x=12, y=13, turn=0}, {x=12, y=14, turn=0},
                {x=12, y=15, turn=0}, {x=12, y=16, turn=0}, {x=12, y=18, turn=0}, {x=12, y=19, turn=0},
                {x=12, y=20, turn=0}, {x=12, y=21, turn=0}, {x=12, y=22, turn=0}, {x=12, y=24, turn=0},
                {x=0, y=12, turn=0}, {x=2, y=12, turn=0}, {x=3, y=12, turn=0}, {x=4, y=12, turn=0}, {x=5, y=12, turn=0},
                {x=6, y=12, turn=0}, {x=8, y=12, turn=0}, {x=9, y=12, turn=0}, {x=10, y=12, turn=0},
                {x=11, y=12, turn=0}, {x=13, y=12, turn=0}, {x=14, y=12, turn=0}, {x=15, y=12, turn=0},
                {x=16, y=12, turn=0}, {x=18, y=12, turn=0}, {x=19, y=12, turn=0}, {x=20, y=12, turn=0},
                {x=21, y=12, turn=0}, {x=22, y=12, turn=0}, {x=24, y=12, turn=0}, {x=10, y=11, turn=0},
                {x=11, y=10, turn=0}, {x=11, y=11, turn=0}, {x=13, y=10, turn=0}, {x=13, y=11, turn=0},
                {x=14, y=11, turn=0}, {x=14, y=13, turn=0}, {x=13, y=13, turn=0}, {x=13, y=14, turn=0},
                {x=10, y=13, turn=0}, {x=11, y=13, turn=0}, {x=11, y=14, turn=0}
            },
            start_positions = {
                {x=1, y=1}, {x=23, y=23}, {x=1, y=23}, {x=23, y=1}, {x=9, y=1}, {x=15, y=23}, {x=9, y=23}, {x=15, y=1},
                {x=1, y=9}, {x=23, y=15}, {x=23, y=9}, {x=1, y=15}, {x=9, y=9}, {x=15, y=15}, {x=9, y=15}, {x=15, y=9}
            }
        }
    },

    -- 11x11 vertical food line, https://www.youtube.com/watch?v=FB2wkxndeog&t=3129s
    {
        name = "11x11 Vertical Food Line",
        definition = {
            width = 11,
            height = 11,
            food_spawns = {
                {x=5, y=0, turn=0}, {x=5, y=1, turn=0}, {x=5, y=2, turn=0}, {x=5, y=3, turn=0}, {x=5, y=4, turn=0},
                {x=5, y=5, turn=0}, {x=5, y=6, turn=0}, {x=5, y=7, turn=0}, {x=5, y=8, turn=0}, {x=5, y=9, turn=0},
                {x=5, y=10, turn=0}
            },
            hazard_spawns = {},
            start_positions = {
                {x=1, y=1}, {x=9, y=9}, {x=1, y=9}, {x=9, y=1}, {x=1, y=3}, {x=9, y=7}, {x=1, y=7}, {x=9, y=3},
                {x=1, y=5}, {x=9, y=5}
            }
        }
    },

    -- 19x19 rings, Normal Hazard Sauce, https://www.youtube.com/watch?v=FB2wkxndeog&t=3536s
    {
        name = "19x19 Rings",
        definition = {
            width = 19,
            height = 19,
            food_spawns = {},
            hazard_spawns = {
                {x=1, y=1, turn=0}, {x=2, y=1, turn=0}, {x=3, y=1, turn=0}, {x=4, y=1, turn=0}, {x=5, y=1, turn=0},
                {x=6, y=1, turn=0}, {x=7, y=1, turn=0}, {x=8, y=1, turn=0}, {x=9, y=1, turn=0}, {x=10, y=1, turn=0},
                {x=11, y=1, turn=0}, {x=12, y=1, turn=0}, {x=13, y=1, turn=0}, {x=14, y=1, turn=0}, {x=15, y=1, turn=0},
                {x=16, y=1, turn=0}, {x=17, y=1, turn=0}, {x=17, y=2, turn=0}, {x=17, y=3, turn=0}, {x=17, y=4, turn=0},
                {x=17, y=5, turn=0}, {x=17, y=6, turn=0}, {x=17, y=7, turn=0}, {x=17, y=8, turn=0}, {x=17, y=9, turn=0},
                {x=17, y=10, turn=0}, {x=17, y=11, turn=0}, {x=17, y=12, turn=0}, {x=17, y=13, turn=0},
                {x=17, y=14, turn=0}, {x=17, y=15, turn=0}, {x=17, y=16, turn=0}, {x=17, y=17, turn=0},
                {x=16, y=17, turn=0}, {x=15, y=17, turn=0}, {x=14, y=17, turn=0}, {x=13, y=17, turn=0},
                {x=12, y=17, turn=0}, {x=11, y=17, turn=0}, {x=10, y=17, turn=0}, {x=9, y=17, turn=0},
                {x=8, y=17, turn=0}, {x=7, y=17, turn=0}, {x=6, y=17, turn=0}, {x=5, y=17, turn=0}, {x=4, y=17, turn=0},
                {x=3, y=17, turn=0}, {x=2, y=17, turn=0}, {x=1, y=17, turn=0}, {x=1, y=16, turn=0}, {x=1, y=15, turn=0},
                {x=1, y=14, turn=0}, {x=1, y=13, turn=0}, {x=1, y=12, turn=0}, {x=1, y=11, turn=0}, {x=1, y=10, turn=0},
                {x=1, y=9, turn=0}, {x=1, y=8, turn=0}, {x=1, y=7, turn=0}, {x=1, y=6, turn=0}, {x=1, y=5, turn=0},
                {x=1, y=4, turn=0}, {x=1, y=3, turn=0}, {x=1, y=2, turn=0}, {x=3, y=3, turn=0}, {x=4, y=3, turn=0},
                {x=5, y=3, turn=0}, {x=6, y=3, turn=0}, {x=7, y=3, turn=0}, {x=8, y=3, turn=0}, {x=9, y=3, turn=0},
                {x=10, y=3, turn=0}, {x=11, y=3, turn=0}, {x=12, y=3, turn=0}, {x=13, y=3, turn=0}, {x=14, y=3, turn=0},
                {x=15, y=3, turn=0}, {x=15, y=4, turn=0}, {x=15, y=5, turn=0}, {x=15, y=6, turn=0}, {x=15, y=7, turn=0},
                {x=15, y=8, turn=0}, {x=15, y=9, turn=0}, {x=15, y=10, turn=0}, {x=15, y=11, turn=0},
                {x=15, y=12, turn=0}, {x=15, y=13, turn=0}, {x=15, y=14, turn=0}, {x=15, y=15, turn=0},
                {x=14, y=15, turn=0}, {x=13, y=15, turn=0}, {x=12, y=15, turn=0}, {x=11, y=15, turn=0},
                {x=10, y=15, turn=0}, {x=9, y=15, turn=0}, {x=8, y=15, turn=0}, {x=7, y=15, turn=0},
                {x=6, y=15, turn=0}, {x=5, y=15, turn=0}, {x=4, y=15, turn=0}, {x=3, y=15, turn=0}, {x=3, y=14, turn=0},
                {x=3, y=13, turn=0}, {x=3, y=12, turn=0}, {x=3, y=11, turn=0}, {x=3, y=10, turn=0}, {x=3, y=9, turn=0},
                {x=3, y=8, turn=0}, {x=3, y=7, turn=0}, {x=3, y=6, turn=0}, {x=3, y=5, turn=0}, {x=3, y=4, turn=0},
                {x=5, y=5, turn=0}, {x=6, y=5, turn=0}, {x=7, y=5, turn=0}, {x=8, y=5, turn=0}, {x=9, y=5, turn=0},
                {x=10, y=5, turn=0}, {x=11, y=5, turn=0}, {x=12, y=5, turn=0}, {x=13, y=5, turn=0}, {x=13, y=6, turn=0},
                {x=13, y=7, turn=0}, {x=13, y=8, turn=0}, {x=13, y=9, turn=0}, {x=13, y=10, turn=0},
                {x=13, y=11, turn=0}, {x=13, y=12, turn=0}, {x=13, y=13, turn=0}, {x=12, y=13, turn=0},
                {x=11, y=13, turn=0}, {x=10, y=13, turn=0}, {x=9, y=13, turn=0}, {x=8, y=13, turn=0},
                {x=7, y=13, turn=0}, {x=6, y=13, turn=0}, {x=5, y=13, turn=0}, {x=5, y=12, turn=0}, {x=5, y=11, turn=0},
                {x=5, y=10, turn=0}, {x=5, y=9, turn=0}, {x=5, y=8, turn=0}, {x=5, y=7, turn=0}, {x=5, y=6, turn=0},
                {x=7, y=7, turn=0}, {x=8, y=7, turn=0}, {x=9, y=7, turn=0}, {x=10, y=7, turn=0}, {x=11, y=7, turn=0},
                {x=11, y=8, turn=0}, {x=11, y=9, turn=0}, {x=11, y=10, turn=0}, {x=11, y=11, turn=0},
                {x=10, y=11, turn=0}, {x=9, y=11, turn=0}, {x=8, y=11, turn=0}, {x=7, y=11, turn=0},
                {x=7, y=10, turn=0}, {x=7, y=9, turn=0}, {x=7, y=8, turn=0}
            },
            start_positions = {}
        }
    },

    -- 11x11 bridges, https://www.youtube.com/watch?v=FB2wkxndeog&t=3749s
    {
        name = "11x11 Bridges",
        definition = {
            width = 11,
            height = 11,
            food_spawns = {
                {x=5, y=2, turn=0}, {x=5, y=8, turn=0}, {x=2, y=5, turn=0}, {x=8, y=5, turn=0}, {x=4, y=4, turn=0},
                {x=6, y=6, turn=0}, {x=4, y=6, turn=0}, {x=6, y=4, turn=0}
            },
            hazard_spawns = {
                {x=5, y=0, turn=0}, {x=5, y=1, turn=0}, {x=5, y=3, turn=0}, {x=5, y=4, turn=0}, {x=5, y=5, turn=0},
                {x=5, y=6, turn=0}, {x=5, y=7, turn=0}, {x=5, y=9, turn=0}, {x=5, y=10, turn=0}, {x=0, y=5, turn=0},
                {x=1, y=5, turn=0}, {x=3, y=5, turn=0}, {x=4, y=5, turn=0}, {x=6, y=5, turn=0}, {x=7, y=5, turn=0},
                {x=9, y=5, turn=0}, {x=10, y=5, turn=0}
            },
            start_positions = {
                {x=1, y=1}, {x=9, y=9}, {x=1, y=9}, {x=9, y=1}
            }
        }
    },

    -- 21x21 rings, https://www.youtube.com/watch?v=pA6q_Yn2Jo8&t=1484s
    {
        name = "21x21 Rings",
        definition = {
            width = 21,
            height = 21,
            food_spawns = {},
            hazard_spawns = {
                {x=1, y=1, turn=0}, {x=2, y=1, turn=0}, {x=3, y=1, turn=0}, {x=4, y=1, turn=0}, {x=5, y=1, turn=0},
                {x=6, y=1, turn=0}, {x=7, y=1, turn=0}, {x=8, y=1, turn=0}, {x=9, y=1, turn=0}, {x=10, y=1, turn=0},
                {x=11, y=1, turn=0}, {x=12, y=1, turn=0}, {x=13, y=1, turn=0}, {x=14, y=1, turn=0}, {x=15, y=1, turn=0},
                {x=16, y=1, turn=0}, {x=17, y=1, turn=0}, {x=18, y=1, turn=0}, {x=19, y=1, turn=0}, {x=19, y=2, turn=0},
                {x=19, y=3, turn=0}, {x=19, y=4, turn=0}, {x=19, y=5, turn=0}, {x=19, y=6, turn=0}, {x=19, y=7, turn=0},
                {x=19, y=8, turn=0}, {x=19, y=9, turn=0}, {x=19, y=10, turn=0}, {x=19, y=11, turn=0},
                {x=19, y=12, turn=0}, {x=19, y=13, turn=0}, {x=19, y=14, turn=0}, {x=19, y=15, turn=0},
                {x=19, y=16, turn=0}, {x=19, y=17, turn=0}, {x=19, y=18, turn=0}, {x=19, y=19, turn=0},
                {x=18, y=19, turn=0}, {x=17, y=19, turn=0}, {x=16, y=19, turn=0}, {x=15, y=19, turn=0},
                {x=14, y=19, turn=0}, {x=13, y=19, turn=0}, {x=12, y=19, turn=0}, {x=11, y=19, turn=0},
                {x=10, y=19, turn=0}, {x=9, y=19, turn=0}, {x=8, y=19, turn=0}, {x=7, y=19, turn=0},
                {x=6, y=19, turn=0}, {x=5, y=19, turn=0}, {x=4, y=19, turn=0}, {x=3, y=19, turn=0}, {x=2, y=19, turn=0},
                {x=1, y=19, turn=0}, {x=1, y=18, turn=0}, {x=1, y=17, turn=0}, {x=1, y=16, turn=0}, {x=1, y=15, turn=0},
                {x=1, y=14, turn=0}, {x=1, y=13, turn=0}, {x=1, y=12, turn=0}, {x=1, y=11, turn=0}, {x=1, y=10, turn=0},
                {x=1, y=9, turn=0}, {x=1, y=8, turn=0}, {x=1, y=7, turn=0}, {x=1, y=6, turn=0}, {x=1, y=5, turn=0},
                {x=1, y=4, turn=0}, {x=1, y=3, turn=0}, {x=1, y=2, turn=0}, {x=3, y=3, turn=0}, {x=4, y=3, turn=0},
                {x=5, y=3, turn=0}, {x=6, y=3, turn=0}, {x=7, y=3, turn=0}, {x=8, y=3, turn=0}, {x=9, y=3, turn=0},
                {x=10, y=3, turn=0}, {x=11, y=3, turn=0}, {x=12, y=3, turn=0}, {x=13, y=3, turn=0}, {x=14, y=3, turn=0},
                {x=15, y=3, turn=0}, {x=16, y=3, turn=0}, {x=17, y=3, turn=0}, {x=17, y=4, turn=0}, {x=17, y=5, turn=0},
                {x=17, y=6, turn=0}, {x=17, y=7, turn=0}, {x=17, y=8, turn=0}, {x=17, y=9, turn=0},
                {x=17, y=10, turn=0}, {x=17, y=11, turn=0}, {x=17, y=12, turn=0}, {x=17, y=13, turn=0},
                {x=17, y=14, turn=0}, {x=17, y=15, turn=0}, {x=17, y=16, turn=0}, {x=17, y=17, turn=0},
                {x=16, y=17, turn=0}, {x=15, y=17, turn=0}, {x=14, y=17, turn=0}, {x=13, y=17, turn=0},
                {x=12, y=17, turn=0}, {x=11, y=17, turn=0}, {x=10, y=17, turn=0}, {x=9, y=17, turn=0},
                {x=8, y=17, turn=0}, {x=7, y=17, turn=0}, {x=6, y=17, turn=0}, {x=5, y=17, turn=0}, {x=4, y=17, turn=0},
                {x=3, y=17, turn=0}, {x=3, y=16, turn=0}, {x=3, y=15, turn=0}, {x=3, y=14, turn=0}, {x=3, y=13, turn=0},
                {x=3, y=12, turn=0}, {x=3, y=11, turn=0}, {x=3, y=10, turn=0}, {x=3, y=9, turn=0}, {x=3, y=8, turn=0},
                {x=3, y=7, turn=0}, {x=3, y=6, turn=0}, {x=3, y=5, turn=0}, {x=3, y=4, turn=0}, {x=5, y=5, turn=0},
                {x=6, y=5, turn=0}, {x=7, y=5, turn=0}, {x=8, y=5, turn=0}, {x=9, y=5, turn=0}, {x=10, y=5, turn=0},
                {x=11, y=5, turn=0}, {x=12, y=5, turn=0}, {x=13, y=5, turn=0}, {x=14, y=5, turn=0}, {x=15, y=5, turn=0},
                {x=15, y=6, turn=0}, {x=15, y=7, turn=0}, {x=15, y=8, turn=0}, {x=15, y=9, turn=0}, {x=15, y=10, turn=0},
                {x=15, y=11, turn=0}, {x=15, y=12, turn=0}, {x=15, y=13, turn=0}, {x=15, y=14, turn=0},
                {x=15, y=15, turn=0}, {x=14, y=15, turn=0}, {x=13, y=15, turn=0}, {x=12, y=15, turn=0},
                {x=11, y=15, turn=0}, {x=10, y=15, turn=0}, {x=9, y=15, turn=0}, {x=8, y=15, turn=0},
                {x=7, y=15, turn=0}, {x=6, y=15, turn=0}, {x=5, y=15, turn=0}, {x=5, y=14, turn=0}, {x=5, y=13, turn=0},
                {x=5, y=12, turn=0}, {x=5, y=11, turn=0}, {x=5, y=10, turn=0}, {x=5, y=9, turn=0}, {x=5, y=8, turn=0},
                {x=5, y=7, turn=0}, {x=5, y=6, turn=0}, {x=7, y=7, turn=0}, {x=8, y=7, turn=0}, {x=9, y=7, turn=0},
                {x=10, y=7, turn=0}, {x=11, y=7, turn=0}, {x=12, y=7, turn=0}, {x=13, y=7, turn=0}, {x=13, y=8, turn=0},
                {x=13, y=9, turn=0}, {x=13, y=10, turn=0}, {x=13, y=11, turn=0}, {x=13, y=12, turn=0},
                {x=13, y=13, turn=0}, {x=12, y=13, turn=0}, {x=11, y=13, turn=0}, {x=10, y=13, turn=0},
                {x=9, y=13, turn=0}, {x=8, y=13, turn=0}, {x=7, y=13, turn=0}, {x=7, y=12, turn=0}, {x=7, y=11, turn=0},
                {x=7, y=10, turn=0}, {x=7, y=9, turn=0}, {x=7, y=8, turn=0}, {x=9, y=9, turn=0}, {x=10, y=9, turn=0},
                {x=11, y=9, turn=0}, {x=11, y=10, turn=0}, {x=11, y=11, turn=0}, {x=10, y=11, turn=0},
                {x=9, y=11, turn=0}, {x=9, y=10, turn=0}
            },
            start_positions = {}
        }
    },

    -- 21x21 dots, https://www.youtube.com/watch?v=pA6q_Yn2Jo8&t=1922s
    {
        name = "21x21 Dots",
        definition = {
            width = 21,
            height = 21,
            food_spawns = {},
            hazard_spawns = {
                {x=1, y=1, turn=0}, {x=3, y=1, turn=0}, {x=5, y=1, turn=0}, {x=7, y=1, turn=0}, {x=9, y=1, turn=0},
                {x=11, y=1, turn=0}, {x=13, y=1, turn=0}, {x=15, y=1, turn=0}, {x=17, y=1, turn=0}, {x=19, y=1, turn=0},
                {x=1, y=3, turn=0}, {x=3, y=3, turn=0}, {x=5, y=3, turn=0}, {x=7, y=3, turn=0}, {x=9, y=3, turn=0},
                {x=11, y=3, turn=0}, {x=13, y=3, turn=0}, {x=15, y=3, turn=0}, {x=17, y=3, turn=0}, {x=19, y=3, turn=0},
                {x=1, y=5, turn=0}, {x=3, y=5, turn=0}, {x=5, y=5, turn=0}, {x=7, y=5, turn=0}, {x=9, y=5, turn=0},
                {x=11, y=5, turn=0}, {x=13, y=5, turn=0}, {x=15, y=5, turn=0}, {x=17, y=5, turn=0}, {x=19, y=5, turn=0},
                {x=1, y=7, turn=0}, {x=3, y=7, turn=0}, {x=5, y=7, turn=0}, {x=7, y=7, turn=0}, {x=9, y=7, turn=0},
                {x=11, y=7, turn=0}, {x=13, y=7, turn=0}, {x=15, y=7, turn=0}, {x=17, y=7, turn=0}, {x=19, y=7, turn=0},
                {x=1, y=9, turn=0}, {x=3, y=9, turn=0}, {x=5, y=9, turn=0}, {x=7, y=9, turn=0}, {x=9, y=9, turn=0},
                {x=11, y=9, turn=0}, {x=13, y=9, turn=0}, {x=15, y=9, turn=0}, {x=17, y=9, turn=0}, {x=19, y=9, turn=0},
                {x=1, y=11, turn=0}, {x=3, y=11, turn=0}, {x=5, y=11, turn=0}, {x=7, y=11, turn=0}, {x=9, y=11, turn=0},
                {x=11, y=11, turn=0}, {x=13, y=11, turn=0}, {x=15, y=11, turn=0}, {x=17, y=11, turn=0},
                {x=19, y=11, turn=0}, {x=1, y=13, turn=0}, {x=3, y=13, turn=0}, {x=5, y=13, turn=0},
                {x=7, y=13, turn=0}, {x=9, y=13, turn=0}, {x=11, y=13, turn=0}, {x=13, y=13, turn=0},
                {x=15, y=13, turn=0}, {x=17, y=13, turn=0}, {x=19, y=13, turn=0}, {x=1, y=15, turn=0},
                {x=3, y=15, turn=0}, {x=5, y=15, turn=0}, {x=7, y=15, turn=0}, {x=9, y=15, turn=0},
                {x=11, y=15, turn=0}, {x=13, y=15, turn=0}, {x=15, y=15, turn=0}, {x=17, y=15, turn=0},
                {x=19, y=15, turn=0}, {x=1, y=17, turn=0}, {x=3, y=17, turn=0}, {x=5, y=17, turn=0},
                {x=7, y=17, turn=0}, {x=9, y=17, turn=0}, {x=11, y=17, turn=0}, {x=13, y=17, turn=0},
                {x=15, y=17, turn=0}, {x=17, y=17, turn=0}, {x=19, y=17, turn=0}, {x=1, y=19, turn=0},
                {x=3, y=19, turn=0}, {x=5, y=19, turn=0}, {x=7, y=19, turn=0}, {x=9, y=19, turn=0},
                {x=11, y=19, turn=0}, {x=13, y=19, turn=0}, {x=15, y=19, turn=0}, {x=17, y=19, turn=0},
                {x=19, y=19, turn=0},
            },
            start_positions = {}
        }
    },
}


-- Returns the list of definitions, sorted by name, as well as a second
-- sorted list of just the definition names. This is so we can use the
-- imgui Combo box to select them.
function CustomGameDefinitions.getDefinitions()

    local names = {}
    for _, definition in ipairs(definitions) do
        table.insert(names, definition.name)
    end

    table.sort(names)
    table.sort(definitions, function(a, b) return a.name < b.name end)

    return names, definitions
end

return CustomGameDefinitions
