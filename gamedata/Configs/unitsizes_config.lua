local SMALL_UNIT_SIZE_MULT = 0.75 --0.71 -- math.sqrt(0.5) rounded up
local LARGE_UNIT_SIZE_MULT = 1.35 --1.41 -- math.sqrt(2.0) rounded down

local SMALL_UNIT_HEALTH_MULT = 0.5
local SMALL_UNIT_POWER_MULT = 0.5
local SMALL_UNIT_RANGE_MULT = 0.8

local LARGE_UNIT_HEALTH_MULT = 2.0
local LARGE_UNIT_POWER_MULT = 2.0
local LARGE_UNIT_RANGE_MULT = 1.2

local LARGE_PLATE_COST = 400
local LARGE_FACTORY_COST = 2000

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
        unitSizeValue = "small",
        unitNamePostfix = "_small",
        humanNamePostfix = " (Small)",
        externalWeaponDefsConfigKey = "small",

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
        unitSizeValue = "medium",
        unitNamePostfix = "",
        humanNamePostfix = " (Medium)",
        externalWeaponDefsConfigKey = "medium",
    },
    large = {
        unitSizeValue = "large",
        unitNamePostfix = "_large",
        humanNamePostfix = " (Large)",
        externalWeaponDefsConfigKey = "large",

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
        unitSizeValue = "factory_medium",
        unitNamePostfix = "",
        humanNamePostfix = " (Medium)",
        externalWeaponDefsConfigKey = "medium",
    },
    factory_large = {
        unitSizeValue = "factory_large",
        unitNamePostfix = "_large",
        humanNamePostfix = " (Large)",
        externalWeaponDefsConfigKey = "large",

        constants = {
            buildcostmetal = LARGE_FACTORY_COST,
            morphTime = 100,
            --morphBuildPower = 15,
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
        unitSizeValue = "plate_medium",
        unitNamePostfix = "",
        humanNamePostfix = " (Medium)",
        externalWeaponDefsConfigKey = "medium",
    },
    plate_large = {
        unitSizeValue = "plate_large",
        unitNamePostfix = "_large",
        humanNamePostfix = " (Large)",
        externalWeaponDefsConfigKey = "large",

        constants = {
            buildcostmetal = LARGE_PLATE_COST,
            morphBuildPower = 10,
        },

        multipliers = {
            size = 1.5,
            health = 2.0,
            buildPower = 1.5, -- 2.0

            yardMapScale = 3, -- 1.5 * 2
            yardMapToHighResolution = true,
        },
    },
}

for key, config in pairs(unitSizesConfig) do
    config.weaponSizeValue        = config.unitSizeValue
    config.weaponNamePostfix      = config.unitNamePostfix
    config.explosionNamePostfix   = config.unitNamePostfix
    config.explosionDefsConfigKey = config.externalWeaponDefsConfigKey
end

SetDefaults(unitSizesConfig.factory_large.multipliers, unitSizesConfig.large.multipliers)
SetDefaults(unitSizesConfig.plate_large.multipliers  , unitSizesConfig.large.multipliers)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return unitSizesConfig
