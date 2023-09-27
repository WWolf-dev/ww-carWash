WashingZones = {
    ["First"] = {
        Blip = {
            Coords = vector3(171.2850, -1722.8196, 29.3917),
            Sprite = 1,
            Scale = 0.8,
            Color = 1,
            Opacity = 254,
            Name = "Car Wash"
        },
        NPC = {
            Coords = vector4(171.2850, -1722.8196, 28.3917, 143.4336),
            Model = "IG_Charlie_Reed",
            AnimDictionnary = "amb@code_human_cower@female@react_cowering",
            AnimName = "base_back_left_exit"
        },

        WashingPlaceForVehicle = vector4(174.6060, -1736.5067, 28.5635, 271.0417),

        StandardWash = {
            ModelNpc1 = "A_F_Y_Beach_01",
            ModelNpc2 = "A_F_Y_Beach_01",
            SpawnNpc1 = vector4(167.0168, -1708.9016, 29.2917, 243.7439),
            SpawnNpc2 = vector4(167.6830, -1707.5642, 29.2917, 214.7195),
            PlaceNpc1Wash = vector4(174.6893, -1734.9972, 29.2921, 175.5587),
            PlaceNpc2Wash = vector4(174.7735, -1738.0529, 29.2903, 358.2640),
        },

        PremiumWash = {
            ModelNpc1 = "A_F_Y_Beach_01",
            ModelNpc2 = "A_F_Y_Beach_01",
            ModelNpc3 = "A_F_Y_Beach_01",
            SpawnNpc1 = vector4(167.0168, -1708.9016, 29.2917, 243.7439),
            SpawnNpc2 = vector4(167.6830, -1707.5642, 29.2917, 214.7195),
            SpawnNpc3 = vector4(166.7763, -1705.4390, 29.2917, 251.4174),
            PlaceNpc1Wash = vector4(174.6893, -1734.9972, 29.2921, 175.5587),
            PlaceNpc2Wash = vector4(174.7735, -1738.0529, 29.2903, 358.2640)
        },
    },
    -- ["Second"] = {
    --     Blip = {
    --         Coords = vector3(171.2850, -1722.8196, 29.3917),
    --         Sprite = 1,
    --         Scale = 0.8,
    --         Color = 1,
    --         Opacity = 254,
    --         Name = "Car Wash"
    --     },
    --     NPC = {
    --         Coords = vector4(171.2850, -1722.8196, 28.3917, 143.4336),
    --         Model = "IG_Charlie_Reed",
    --         AnimDictionnary = "amb@code_human_cower@female@react_cowering",
    --         AnimName = "base_back_left_exit"
    --     },
    --     Prices = {
    --         ["Manual"] = 100,
    --         ["Standard"] = 200,
    --         ["Premium"] = 300
    --     }
    -- },
}

Prices = {
    ["Manual"] = 100,
    ["Standard"] = 200,
    ["Premium"] = 300
}

ManualWash = {
    ItemUseToWash = "carwashkit",
    NumberGivenToPlayer = 1,
}