--Spring.Echo("UnitSizes unitdefs_mod.lua")

--VFS.Include('gamedata/unitdefs_analyzer.lua', nil, VFS.GAME)

local unitSizesConfig = VFS.Include("gamedata/Configs/unitsizes_config.lua", nil, VFS.GAME)

VFS.Include("LuaRules/Utilities/tablefunctions.lua")
local CopyTable = Spring.Utilities.CopyTable

local round = math.round or function (x)
    return math.floor(x + 0.5)
end

--------------------------------------------------------------------------------

local factories = {
    [[factoryshield]],
	[[factorycloak]],
	[[factoryveh]],
	[[factoryplane]],
	[[factorygunship]],
	[[factoryhover]],
	[[factoryamph]],
	[[factoryspider]],
	[[factoryjump]],
	[[factorytank]],
	[[factoryship]],

	[[striderhub]],
}

local plates = {
	[[plateshield]],
	[[platecloak]],
	[[plateveh]],
	[[plateplane]],
	[[plategunship]],
	[[platehover]],
	[[plateamph]],
	[[platespider]],
	[[platejump]],
	[[platetank]],
	[[plateship]],
}

local otherBuilders = {
    [[athena]],
}

local otherUnits = {
    -- drones
    [[dronecarry]],
}

--------------------------------------------------------------------------------

local factoriesByName = {}
local factoriesUnitsByName = {}
local platesByName = {}
local otherUnitsByName = {}

for _, factoryUnitName in ipairs (factories) do
    local factoryDef = UnitDefs[factoryUnitName]
    local buildoptions = factoryDef and factoryDef.buildoptions or {}

    factoriesByName[factoryUnitName] = true

    for _, unitName in ipairs (buildoptions) do
        factoriesUnitsByName[unitName] = true
    end
end

for _, plateUnitName in ipairs (plates) do
    platesByName[plateUnitName] = true
end

-- Other units
for _, unitName in ipairs (otherUnits) do
    otherUnitsByName[unitName] = true
end

-- include units morphable from factory units
for unitName, _ in pairs (factoriesUnitsByName) do
    local ud = UnitDefs[unitName]
    local morphUnitName = ud.customparams and ud.customparams.morphto

    if (morphUnitName and not factoriesUnitsByName[morphUnitName]) then
        otherUnitsByName[morphUnitName] = true
    end
end

--------------------------------------------------------------------------------

--Spring.Utilities.TableEcho(UnitDefs, "UnitDefs")

local function applyMult(def, tag, mult)
    if (def[tag]) then
        def[tag] = tonumber(def[tag]) * mult
    end
end

local function applyMultAndRound(def, tag, mult)
    if (def[tag]) then
        def[tag] = round(tonumber(def[tag]) * mult)
    end
end

local function applyMultToFootprint(def, tag, mult, config)
    if (def[tag]) then
        local oldValue = tonumber(def[tag])
        if (config.footprintConversions and config.footprintConversions[oldValue]) then
            def[tag] = config.footprintConversions[oldValue]
        else
            def[tag] = round(oldValue * mult)
        end
    end
end

local function applyMultToVector(def, tag, mult)
    if (def[tag]) then
        local oldValues = def[tag]
        local newValues = {}
        for value in string.gmatch(oldValues, "%S+") do
            newValues[ #newValues + 1 ] = tonumber(value) * mult
        end
        def[tag] = table.concat(newValues, " ")
    end
end

local function applyMultToVectorAndRound(def, tag, mult)
    if (def[tag]) then
        local oldValues = def[tag]
        local newValues = {}
        for value in string.gmatch(oldValues, "%S+") do
            newValues[ #newValues + 1 ] = round(tonumber(value) * mult)
        end
        def[tag] = table.concat(newValues, " ")
    end
end

local function applyUnitDefCostMult (ud, costMult)
    applyMultAndRound(ud, "buildcostmetal", costMult)
    applyMultAndRound(ud.customparams, "grey_goo_cost", costMult)
    applyMult(ud, "power", costMult)
end

local function scaleUnitDefYardMap (ud, multipliers, unscaledFootprintx, unscaledFootprintz)
    if (ud.yardmap) then
        if (multipliers.yardMapScale and multipliers.yardMapScale ~= 1 and unscaledFootprintx) then
            local yardmap = string.gsub(ud.yardmap, " ", "")

            local yardmapLength = #yardmap
            local lineLength = unscaledFootprintx
            local numLines = unscaledFootprintz

            local highResolutionMult = (multipliers.yardMapToHighResolution and 2 or 1)
            local centerCharsToAdd = (ud.footprintx * highResolutionMult) - (unscaledFootprintx * multipliers.yardMapScale)
            local centerLinesToAdd = (ud.footprintz * highResolutionMult) - (unscaledFootprintz * multipliers.yardMapScale)

            local centerLine = math.floor((numLines - 1) / 2)
            local centerIndex = 1 + centerLine * lineLength

            local scaledYardMap = ""

            for i = 1, yardmapLength, lineLength do
                local lineEnd = math.min(i + lineLength - 1, yardmapLength)
                local lineCenter = i + math.floor((lineLength - 1) / 2)
                local scaledLine = ""

                for j = i, lineEnd do
                    local char = string.sub(yardmap, j, j)
                    local numCharRepeats = (j == lineCenter) and (multipliers.yardMapScale + centerCharsToAdd) or multipliers.yardMapScale
                    local scaledChar = string.rep(char, numCharRepeats)
                    scaledLine = scaledLine .. scaledChar
                end

                local numLineRepeats = (i == centerIndex) and (multipliers.yardMapScale + centerLinesToAdd) or multipliers.yardMapScale
                local multipliedLine = string.rep(scaledLine .. " ", numLineRepeats)
                scaledYardMap = scaledYardMap .. multipliedLine
            end

            ud.yardmap = string.sub(scaledYardMap, 1, -2)
        end
        if (multipliers.yardMapToHighResolution) then
            ud.yardmap = "h" .. ud.yardmap
        end
    end
end

local function applyUnitDefFeatureMults (ud, sizeMult, config)
    if (ud.featuredefs) then
        for _, fd in pairs(ud.featuredefs) do
            applyMultToVector(fd, "collisionvolumeoffsets", sizeMult)
            applyMultToVector(fd, "collisionvolumescales", sizeMult)
            applyMult(fd, "collisionspherescale", sizeMult)
            applyMultToFootprint(fd, "footprintx", sizeMult, config)
            applyMultToFootprint(fd, "footprintz", sizeMult, config)
        end
    end
end

local function applyUnitDefSizeMult (ud, multipliers, config)
    local sizeMult = multipliers.size

    ud.customparams.unitsizemult  = sizeMult
    ud.customparams.modelsizemult = sizeMult

    -- footprint-related
    local unscaledFootprintx = ud.footprintx
    local unscaledFootprintz = ud.footprintz
    applyMultToFootprint(ud, "footprintx", sizeMult, config)
    applyMultToFootprint(ud, "footprintz", sizeMult, config)
    scaleUnitDefYardMap(ud, multipliers, unscaledFootprintx, unscaledFootprintz)

    applyMultToFootprint(ud, "transportsize", sizeMult, config)
    applyMult(ud.customparams, "decloak_footprint", sizeMult)
    applyMultAndRound(ud, "buildinggrounddecalsizex", sizeMult)
    applyMultAndRound(ud, "buildinggrounddecalsizey", sizeMult)
    applyMult(ud, "trackwidth", sizeMult)
    applyMult(ud, "trackoffset", sizeMult)
    applyMult(ud.customparams, "pylonrange", sizeMult)

    -- height-related
    applyMult(ud.customparams, "custom_height", sizeMult)
    applyMult(ud, "losemitheight", sizeMult)
    applyMult(ud, "radaremitheight", sizeMult)
    applyMult(ud.customparams, "shield_emit_height", sizeMult)
    applyMult(ud.customparams, "shield_emit_offset", sizeMult)
    applyMult(ud, "waterline", sizeMult)
    applyMult(ud.customparams, "amph_submerged_at", sizeMult)

    -- volume-related
    applyMult(ud.customparams, "modelradius", sizeMult)
    applyMultToVector(ud, "modelcenteroffset", sizeMult)
    applyMultToVectorAndRound(ud.customparams, "midposoffset", sizeMult)
    applyMultToVectorAndRound(ud.customparams, "aimposoffset", sizeMult)
    applyMult(ud, "collisionspherescale", sizeMult)
    applyMultToVector(ud, "collisionvolumeoffsets", sizeMult)
    applyMultToVector(ud, "collisionvolumescales", sizeMult)
    applyMultToVector(ud, "selectionvolumeoffsets", sizeMult)
    applyMultToVector(ud, "selectionvolumescales", sizeMult)

    --ud.customparams.selection_scale = ud.customparams.selection_scale or 1.0
    --applyMult(ud.customparams, "selection_scale", sizeMult)
    --applyMult(ud.customparams, "selectionscalemult", sizeMult)

    applyUnitDefFeatureMults(ud, sizeMult, config)
end

local function applyUnitDefHealthMult (ud, healthMult)
    applyMult(ud, "maxdamage", healthMult)
    applyMult(ud, "autoheal", healthMult)
    applyMult(ud, "idleautoheal", healthMult)
    applyMult(ud.customparams, "amph_regen", healthMult)
    applyMult(ud.customparams, "armored_regen", healthMult)
end

local function applyUnitDefSpeedMult (ud, speedMult)
    applyMult(ud, "maxvelocity", speedMult)
    applyMult(ud, "maxreversevelocity", speedMult)
    applyMult(ud, "verticalspeed", speedMult)
    applyMult(ud, "acceleration", speedMult)
    applyMult(ud, "maxacc", speedMult)
    applyMult(ud, "brakerate", speedMult)
    applyMult(ud, "turnrate", speedMult)
    applyMult(ud.customparams, "jump_speed", speedMult)
end

local function applyUnitDefResourceMults (ud, multipliers)
    applyMult(ud, "metalstorage", multipliers.resourceMult)
    applyMult(ud, "energystorage", multipliers.resourceMult)
    applyMult(ud, "metalmake", multipliers.resourceMult)
    applyMult(ud, "energymake", multipliers.resourceMult)
    applyMult(ud, "energyuse", multipliers.resourceMult)
    applyMult(ud, "cloakcost", multipliers.resourceMult)
    applyMult(ud, "cloakcostmoving", multipliers.resourceMult)
    applyMult(ud.customparams, "area_cloak_upkeep", multipliers.resourceMult)
    applyMult(ud.customparams, "neededlink", multipliers.resourceMult)

    applyMult(ud, "workertime", multipliers.buildPower)
    applyMult(ud, "resurrectspeed", multipliers.buildPower)
    applyMult(ud, "builddistance", multipliers.buildRange)
    applyMult(ud.customparams, "grey_goo_drain", multipliers.buildPower)
    applyMult(ud.customparams, "grey_goo_range", multipliers.buildRange)
end

local function applyUnitDefSensorMults (ud, multipliers)
    applyMult(ud, "sightdistance", multipliers.losRange)
    applyMult(ud, "radardistance", multipliers.sensorRange)
    applyMult(ud, "sonardistance", multipliers.sensorRange)
    applyMult(ud, "seismicdistance", multipliers.sensorRange)
    applyMult(ud, "radardistancejam", multipliers.sensorRange)
    applyMult(ud, "mincloakdistance", multipliers.sensorRange)
    applyMult(ud.customparams, "area_cloak_radius", multipliers.areaCloakRange)
    applyMult(ud.customparams, "area_cloak_self_decloak_distance", multipliers.sensorRange)
end

local function applyUnitDefSpecialAbilityMults (ud, multipliers)
    applyMult(ud, "transportmass", multipliers.specialAbilityPower)
    applyMult(ud.customparams, "teleporter_throughput", multipliers.specialAbilityPower)
    applyMult(ud.customparams, "thrower_gather", multipliers.specialAbilityRange)
    applyMult(ud.customparams, "jump_range", multipliers.specialAbilityRange)
    applyMult(ud.customparams, "jump_height", multipliers.specialAbilityRange)
end

local function applyUnitDefWeaponMults (ud, multipliers)
    if (ud.weapondefs) then
        for _, wd in pairs(ud.weapondefs) do
            if not wd.customparams then
                wd.customparams = {}
            end

            for dmgKey, dmgValue in pairs(wd.damage) do
                wd.damage[dmgKey] = dmgValue * multipliers.damage
            end

            applyMult(wd.customparams, "extra_damage", multipliers.damage)
            applyMult(wd.customparams, "area_damage_dps", multipliers.damage)
            applyMult(wd.customparams, "timeslow_damage", multipliers.damage)
            applyMult(wd.customparams, "damage_vs_feature", multipliers.damage)
            applyMult(wd.customparams, "damage_vs_shield", multipliers.damage)
            applyMult(wd.customparams, "stats_damage", multipliers.damage)
            applyMult(wd.customparams, "impulse", multipliers.damage)
            applyMult(wd.customparams, "shield_drain", multipliers.damage)
            applyMult(wd, "camerashake", multipliers.damage)
            --applyMult(wd.customparams, "falldamageimmunity", multipliers.damage)

            applyMult(wd, "areaofeffect", multipliers.aoe)
            applyMult(wd, "craterareaofeffect", multipliers.aoe)
            applyMult(wd.customparams, "area_damage_radius", multipliers.aoe)
            applyMult(wd.customparams, "area_damage_plateau_radius", multipliers.aoe)
            applyMult(wd.customparams, "area_damage_height_max", multipliers.aoe)
            applyMult(wd.customparams, "area_damage_height_int", multipliers.aoe)
            applyMult(wd.customparams, "area_damage_height_reduce", multipliers.aoe)
            applyMult(wd.customparams, "gatherradius", multipliers.aoe)
            applyMult(wd.customparams, "smoothradius", multipliers.aoe)
            applyMult(wd.customparams, "detachmentradius", multipliers.aoe)
            --applyMult(wd, "light_radius", multipliers.aoe)

            applyMult(wd, "range", multipliers.range)
            applyMult(wd, "dyndamagerange", multipliers.range)
            applyMult(wd.customparams, "combatrange", multipliers.range)
            applyMult(wd.customparams, "gui_draw_range", multipliers.range)
            applyMult(wd, "flighttime", multipliers.range)

            applyMult(wd, "laserflaresize", multipliers.projectileSize)
            applyMult(wd, "thickness", multipliers.projectileSize)
            applyMult(wd, "corethickness", multipliers.projectileSize)

            applyMult(wd, "shieldpower", multipliers.shieldPower)
            applyMult(wd, "shieldstartingpower", multipliers.shieldPower)
            applyMult(wd, "shieldpowerregen", multipliers.shieldPower)
            applyMult(wd, "shieldpowerregenenergy", multipliers.shieldPower)
            applyMult(wd, "shieldradius", multipliers.shieldRange)

            applyMult(wd, "metalpershot", multipliers.weaponCostMult)
            applyMult(wd, "energypershot", multipliers.weaponCostMult)
        end
    end

    applyMult(ud, "cruisealt", multipliers.range) -- fly height depends on range to avoid issues with small units flying too high for their small range
    applyMult(ud, "kamikazedistance", multipliers.range)
    applyMult(ud.customparams, "percieved_range", multipliers.range)
    applyMult(ud.customparams, "fire_towards_range_buffer", multipliers.range)
    applyMult(ud.customparams, "set_target_range_buffer", multipliers.range)
    applyMult(ud.customparams, "fighter_pullup_dist", multipliers.range)

    applyMult(ud.customparams, "stockpilecost", multipliers.weaponCostMult)
end

local function applyFactoryDefMultipliers (ud, multipliers, config)
    applyUnitDefSizeMult(ud, multipliers, config)
    applyUnitDefHealthMult (ud, multipliers.health)
    applyUnitDefResourceMults (ud, multipliers)
    applyUnitDefSensorMults (ud, multipliers)
end

local function applyUnitDefMultipliers (ud, multipliers, config)
    applyUnitDefCostMult(ud, multipliers.cost)
    applyUnitDefSizeMult(ud, multipliers, config)
    applyUnitDefHealthMult (ud, multipliers.health)
    applyUnitDefSpeedMult(ud, multipliers.speed)
    applyUnitDefResourceMults (ud, multipliers)
    applyUnitDefSensorMults (ud, multipliers)
    applyUnitDefSpecialAbilityMults (ud, multipliers)
    applyUnitDefWeaponMults(ud, multipliers)
end

local function setDefaultsForMissingTags (ud)
    if (not ud.script) then
        ud.script = ud.unitname .. ".cob"
    end
end

local function applyFactoryDefSizeConfig (ud, config)
    ud.customparams.unitsize = config.unitSizeValue
    ud.unitname = ud.unitname .. config.unitNamePostfix
    ud.name = ud.name .. config.humanNamePostfix

    ud.buildcostmetal = config.constants.buildcostmetal

    if (ud.customparams.parent_of_plate) then
        ud.customparams.parent_of_plate = ud.customparams.parent_of_plate .. config.unitNamePostfix
    end
    if (ud.customparams.child_of_factory) then
        ud.customparams.child_of_factory = ud.customparams.child_of_factory .. config.unitNamePostfix
    end

    applyFactoryDefMultipliers(ud, config.multipliers, config)
end

local function applyUnitDefSizeConfig (ud, config)
    ud.customparams.unitsize = config.unitSizeValue
    ud.unitname = ud.unitname .. config.unitNamePostfix
    ud.name = ud.name .. config.humanNamePostfix

    if (ud.customparams.morphto) then
        ud.customparams.morphto = ud.customparams.morphto .. config.unitNamePostfix
    end

    applyUnitDefMultipliers(ud, config.multipliers, config)
end

local function processBuildOptions (buildoptions, includedSizesArray)
    local newBuildOptions = {}

    for _, unitSize in ipairs(includedSizesArray) do
        local unitNamePostfix = unitSizesConfig[unitSize].unitNamePostfix

        for _, unitName in ipairs (buildoptions) do
            local unitNameWithPostfix = unitName .. unitNamePostfix
            if (UnitDefs[unitNameWithPostfix]) then
                newBuildOptions[ #newBuildOptions + 1 ] = unitNameWithPostfix
            end
        end
    end

    return newBuildOptions
end

local function CreateNewUnitDefs (processUnitDefFunc)
    local newUnitDefs = {}

    for _, ud in pairs (UnitDefs) do
        processUnitDefFunc(ud, newUnitDefs)
    end

    CopyTable(newUnitDefs, false, UnitDefs)
end

CreateNewUnitDefs(function (ud, newUnitDefs)
    local isFactoryUnit = factoriesUnitsByName[ ud.unitname ]
    local isOtherUnit = otherUnitsByName[ ud.unitname ]

    if (isFactoryUnit or isOtherUnit) then
        if (not ud.customparams) then
            ud.customparams = {}
        end

        setDefaultsForMissingTags(ud)
        ud.customparams.sourceunit = ud.unitname
        ud.customparams.statsname = ud.customparams.statsname or ud.unitname  -- for translations

        local isNotExcluded = (not unitSizesConfig.small.excludedUnits[ ud.unitname ])
        local isAboveMinCost = (ud.buildcostmetal >= unitSizesConfig.small.limits.minUnitCost)
        local canBeSmall = isNotExcluded and (isAboveMinCost or isOtherUnit)

        if (canBeSmall) then
            local smallUd = CopyTable(ud, true)
            applyUnitDefSizeConfig(smallUd, unitSizesConfig.small)
            newUnitDefs[ smallUd.unitname ] = smallUd
        end

        local largeUd = CopyTable(ud, true)
        applyUnitDefSizeConfig(largeUd, unitSizesConfig.large)
        newUnitDefs[ largeUd.unitname ] = largeUd

        local mediumConfig = unitSizesConfig.medium
        ud.customparams.unitsize = mediumConfig.unitSizeValue
        ud.name = ud.name .. mediumConfig.humanNamePostfix
    end
end)

local function CreateFactoriesUnitDefs (factoriesByName, mediumConfig, largeConfig)
    CreateNewUnitDefs(function (ud, newUnitDefs)
        local isFactory = factoriesByName[ ud.unitname ]

        if (isFactory) then
            if (not ud.customparams) then
                ud.customparams = {}
            end

            setDefaultsForMissingTags(ud)
            ud.customparams.sourceunit = ud.unitname
            ud.customparams.statsname = ud.customparams.statsname or ud.unitname  -- for translations

            local largeUd = CopyTable(ud, true)

            ud.customparams.unitsize = mediumConfig.unitSizeValue
            ud.name = ud.name .. mediumConfig.humanNamePostfix

            ud.buildoptions = processBuildOptions(ud.buildoptions, { "small", "medium" })

            applyFactoryDefSizeConfig(largeUd, largeConfig)
            largeUd.buildoptions = processBuildOptions(largeUd.buildoptions, { "small", "medium", "large" })

            newUnitDefs[ largeUd.unitname ] = largeUd

            ud.customparams.morphto = largeUd.unitname
            if (largeConfig.constants.morphTime) then
                ud.customparams.morphtime = largeConfig.constants.morphTime
            else
                ud.customparams.morphtime = math.floor((largeUd.buildcostmetal - ud.buildcostmetal) / largeConfig.constants.morphBuildPower)
            end
        end
    end)
end

CreateFactoriesUnitDefs(factoriesByName, unitSizesConfig.factory_medium, unitSizesConfig.factory_large)
CreateFactoriesUnitDefs(platesByName   , unitSizesConfig.plate_medium  , unitSizesConfig.plate_large)

-- otherBuilders were already processed as factory units, here it only adds buildoptions and morph data
for _, unitName in ipairs(otherBuilders) do
    local ud = UnitDefs[unitName]

    if ud then
        ud.buildoptions = processBuildOptions(ud.buildoptions, { "small", "medium" })

        local largeUnitName = unitName .. unitSizesConfig.large.unitNamePostfix
        local largeUd = UnitDefs[largeUnitName]

        if largeUd then
            largeUd.buildoptions = processBuildOptions(largeUd.buildoptions, { "small", "medium", "large" })

            ud.customparams.morphto = largeUd.unitname
            ud.customparams.morphtime = math.floor((largeUd.buildcostmetal - ud.buildcostmetal) / ud.workertime)
        end
    end
end

--Spring.Utilities.TableEcho(UnitDefs, "UnitDefs modified")
