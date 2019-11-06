Config = {}

Config.Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Config.Locations = {
    ["normal"] = {
        ["label"] = "LTD Gasoline",
        ["coords"] = {
            [1] = {
                ["x"] = -48.44,
                ["y"] = -1757.86,
                ["z"] = 29.42,
            },
            [2] = {
                ["x"] = -47.23,
                ["y"] = -1756.58,
                ["z"] = 29.42,
            }
        },
    },
    ["hardware"] = {
        ["label"] = "Hardware Store",
        ["coords"] = {
            [1] = {
                ["x"] = 45.55,
                ["y"] = -1749.01,
                ["z"] = 29.6,
            }
        },
    },
    ["coffeeshop"] = {
        ["label"] = "Superfly",
        ["coords"] = {
            [1] = {
                ["x"] = -1172.43,
                ["y"] = -1572.24,
                ["z"] = 4.66,
            }
        },
    }
}

Config.Products = {
    ["normal"] = {
        label = "Supermarktje :)",
        items = {
            [1] = {
                name = "tosti",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 1,
            },
            [2] = {
                name = "repairkit",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 2,
            },
        }
    },
    ["coffeeshop"] = {
        label = "Superfly",
        items = {
            [1] = {
                name = "weed_skunk_seed",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 1,
            },
            [2] = {
                name = "weed_amnesia_seed",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 2,
            },
            [3] = {
                name = "weed_white-widow_seed",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 3,
            },
            [4] = {
                name = "weed_ak47_seed",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 4,
            },
            [5] = {
                name = "joint",
                price = 50,
                amount = 99,
                info = {},
                type = "item",
                slot = 5,
            },
        }
    }
}