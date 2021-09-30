local SMALL_UNIT_SIZE_MULT = 0.75 --0.71 -- math.sqrt(0.5) rounded up
local LARGE_UNIT_SIZE_MULT = 1.35 --1.41 -- math.sqrt(2.0) rounded down

local SMALL_UNIT_HEALTH_MULT = 0.5
local SMALL_UNIT_POWER_MULT = 0.5
local SMALL_UNIT_RANGE_MULT = 0.8

local LARGE_UNIT_HEALTH_MULT = 2.0
local LARGE_UNIT_POWER_MULT = 2.0
local LARGE_UNIT_RANGE_MULT = 1.2

local LARGE_PLATE_COST = 400
local LARGE_FACTORY_COST = 1800

--------------------------------------------------------------------------------

local function ArrayToSet (array)
    local set = {}
    for _, value in ipairs (array) do
        set[value] = true
    end
    return set
end

local function SetDefaults (obj, defaultsObj)
    for key, value in pairs(defaultsObj) do
        if (obj[key] == nil) then
            obj[key] = value
        end
    end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local unitSizesConfig = {
    small = {
        mainConfigKey = "small",
        unitNamePostfix = "_small",
        humanNamePostfix = " (Small)",
        buildPicPostfix = "_small",

        multipliers = {
            cost = 0.5,
            size = SMALL_UNIT_SIZE_MULT,
            health = SMALL_UNIT_HEALTH_MULT,
            shieldPower = SMALL_UNIT_HEALTH_MULT,
            shieldRange = SMALL_UNIT_SIZE_MULT,
            areaCloakRange = SMALL_UNIT_SIZE_MULT,
            speed = 1.15,
            resourceMult = SMALL_UNIT_POWER_MULT,
            buildPower = SMALL_UNIT_POWER_MULT,
            buildRange = SMALL_UNIT_RANGE_MULT,
            losRange = SMALL_UNIT_RANGE_MULT,
            sensorRange = SMALL_UNIT_RANGE_MULT,
            specialAbilityPower = SMALL_UNIT_POWER_MULT,
            specialAbilityRange = SMALL_UNIT_RANGE_MULT,
            damage = SMALL_UNIT_POWER_MULT,
            aoe = SMALL_UNIT_SIZE_MULT,
            range = SMALL_UNIT_RANGE_MULT,
            weaponCostMult = SMALL_UNIT_POWER_MULT,
            projectileSize = SMALL_UNIT_SIZE_MULT,
        },

        footprintConversions = {
            --[1] = 1,
            [2] = 2,
            [3] = 2,
            [4] = 3,
            [5] = 4, -- only used for BOAT5 movementClass
        },

        footprintOverrides = {
            ["subraider"] = 3,
            ["subtacmissile"] = 3,
        },

        moveClassOverrides = {
            ["subraider"] = "UBOAT3",
            ["subtacmissile"] = "UBOAT3",
        },

        -- Units for which small variant should be not created
        excludedUnits = ArrayToSet({
            -- All cons to mantain normal speed of expansion etc.
            [[cloakcon]],
            [[shieldcon]],
            [[vehcon]],
            [[hovercon]],
            [[gunshipcon]],
            [[planecon]],
            [[spidercon]],
            [[jumpcon]],
            [[tankcon]],
            [[amphcon]],
            [[shipcon]],

            -- Athena because smaller faster cheaper Athena would be OP
            [[athena]],

            -- Utility units because utilities should have minimum cost
            -- [[cloakjammer]],
            -- [[staticjammer]].
            [[amphlaunch]],
            [[amphtele]],
        }),

        limits = {
            minUnitCost = 60,
        },
    },
    medium = {
        mainConfigKey = "medium",
        unitNamePostfix = "",
        humanNamePostfix = " (Medium)",
        buildPicPostfix = "_medium",
    },
    large = {
        mainConfigKey = "large",
        unitNamePostfix = "_large",
        humanNamePostfix = " (Large)",
        buildPicPostfix = "_large",

        multipliers = {
            cost = 2.5,
            size = LARGE_UNIT_SIZE_MULT,
            health = LARGE_UNIT_HEALTH_MULT,
            shieldPower = LARGE_UNIT_HEALTH_MULT,
            shieldRange = 1.30,
            areaCloakRange = LARGE_UNIT_SIZE_MULT,
            speed = 0.85,
            resourceMult = LARGE_UNIT_POWER_MULT,
            buildPower = LARGE_UNIT_POWER_MULT,
            buildRange = LARGE_UNIT_RANGE_MULT,
            losRange = LARGE_UNIT_RANGE_MULT,
            sensorRange = LARGE_UNIT_RANGE_MULT,
            specialAbilityPower = LARGE_UNIT_POWER_MULT,
            specialAbilityRange = LARGE_UNIT_RANGE_MULT,
            damage = LARGE_UNIT_POWER_MULT,
            aoe = LARGE_UNIT_SIZE_MULT,
            range = LARGE_UNIT_RANGE_MULT,
            weaponCostMult = LARGE_UNIT_POWER_MULT,
            projectileSize = LARGE_UNIT_SIZE_MULT,

            yardMapScale = 1, -- Let the yardMap scaling code automatically add missing chars to fill footprint size.
            yardMapToHighResolution = false,
        },

        footprintConversions = {
            --[1] = 2,
            [2] = 3,
            [3] = 4,
            [4] = 6,
            [5] = 7, -- only used for BOAT5 movementClass
        },

        footprintOverrides = {
            -- Large variants of some small units are still small enough to fit in the 2x2 footprint
            ["cloakbomb"]   = 2, -- Imp
            ["cloakraid"]   = 2, -- Glaive
            ["gunshipbomb"] = 2, -- Blastwing
            ["gunshipemp"]  = 2, -- Gnat
            ["jumpscout"]   = 2, -- Puppy
            ["shieldbomb"]  = 2, -- Snitch
            ["shieldraid"]  = 2, -- Bandit
            ["spiderscout"] = 2, -- Flea
        },
    },
    factory_medium = {
        mainConfigKey = "medium",
        unitNamePostfix = "",
        humanNamePostfix = " (Medium)",
        buildPicPostfix = "_medium",
    },
    factory_large = {
        mainConfigKey = "large",
        unitNamePostfix = "_large",
        humanNamePostfix = " (Large)",
        buildPicPostfix = "_large",

        constants = {
            buildcostmetal = LARGE_FACTORY_COST,
            --morphTime = 110,
            morphBuildPower = 10,
        },

        multipliers = {
            size = 1.5,
            health = 2.0,
            buildPower = 2.0,

            yardMapScale = 3, -- 1.5 * 2
            yardMapToHighResolution = true,
        },

        footprintConversions = {
            [4] = 6, -- only used for striderhub unit movementClass
        },
    },
    plate_medium = {
        mainConfigKey = "medium",
        unitNamePostfix = "",
        humanNamePostfix = " (Medium)",
        buildPicPostfix = "_medium",
    },
    plate_large = {
        mainConfigKey = "large",
        unitNamePostfix = "_large",
        humanNamePostfix = " (Large)",
        buildPicPostfix = "_large",

        constants = {
            buildcostmetal = LARGE_PLATE_COST,
            morphBuildPower = 10,
        },

        multipliers = {
            size = 1.5,
            health = 2.0,
            buildPower = 2.0,

            yardMapScale = 3, -- 1.5 * 2
            yardMapToHighResolution = true,
        },
    },
}

for configKey, config in pairs(unitSizesConfig) do
    config.configKey            = configKey
    config.buildPicConfigKey    = config.mainConfigKey
    config.weaponNamePostfix    = config.unitNamePostfix
    config.explosionNamePostfix = "_modded" .. config.unitNamePostfix  -- some existing explosions already have "_small" or "_large" postfix
end

SetDefaults(unitSizesConfig.factory_large.multipliers, unitSizesConfig.large.multipliers)
SetDefaults(unitSizesConfig.plate_large.multipliers  , unitSizesConfig.large.multipliers)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return unitSizesConfig
