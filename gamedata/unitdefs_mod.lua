Spring.Echo("Loading UnitDefs_mod")

--VFS.Include('gamedata/unitdefs_analyzer.lua', nil, VFS.GAME)

local unitSizesConfig = VFS.Include("gamedata/Configs/unitsizes_config.lua", nil, VFS.GAME)

local moveDefs = VFS.Include("gamedata/movedefs.lua", nil, VFS.GAME)

VFS.Include("LuaRules/Utilities/tablefunctions.lua")
local CopyTable = Spring.Utilities.CopyTable

local lower         = string.lower
local string_sub    = string.sub
local string_rep    = string.rep
local string_match  = string.match
local string_gmatch = string.gmatch
local string_gsub   = string.gsub

local round = math.round or function (x)
    return math.floor(x + 0.5)
end

local defaultMapGravity = 120
local defaultMyGravity  = defaultMapGravity / (Game.gameSpeed ^ 2)

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

local buildOptionReplacements = {
    ["athena"] = {
        {
            buildOption = "staticjammer",
            replacementSizes = { "small", "medium", "large" }
        }
    }
}

local otherUnits = {
    -- drones
    [[dronecarry]],

    -- mines
    -- [[wolverine_mine]], -- discovered automatically

    -- morphable units
    -- [[staticjammer]], -- discovered automatically
    -- [[staticshield]],
}

local excludedProjectileModels = {
    ["emptyModel.s3o"] = true, -- used only on fake weapons
}

local excludedExplosionGenerators = {
    ["default"] = true, -- generators with no spawners
    ["none"] = true,
}

--------------------------------------------------------------------------------

local factoriesByName = {}
local factoriesUnitsByName = {}
local platesByName = {}
local otherUnitsByName = {}
local moveDefsByName = {}
local externalWeaponDefVariants = {}
local explosionDefVariants = {}

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

for unitName, _ in pairs (factoriesUnitsByName) do
    local ud = UnitDefs[unitName]

    -- include units morphable from factory units
    local morphUnitName = ud.customparams and ud.customparams.morphto

    if (morphUnitName and not factoriesUnitsByName[morphUnitName]) then
        otherUnitsByName[morphUnitName] = true
    end

    -- include units spawned by grey goo
    local greyGooUnitName = ud.customparams and ud.customparams.grey_goo_spawn

    if (greyGooUnitName and not factoriesUnitsByName[greyGooUnitName]) then
        otherUnitsByName[greyGooUnitName] = true
    end

    -- include mines
    if (ud.weapondefs) then
        for _, wd in pairs(ud.weapondefs) do
            local mineUnitName = wd.customparams and wd.customparams.spawns_name

            if (mineUnitName) then
                otherUnitsByName[mineUnitName] = true
            end
        end
    end
end

-- Move defs
for _, moveDef in ipairs (moveDefs) do
    moveDefsByName[ moveDef.name ] = true
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

local function applyMultToFootprint(ud, def, tag, mult, config)
    if (def[tag]) then
        local sourceUnitName = ud.customparams.sourceunit

        if (config.footprintOverrides and config.footprintOverrides[ sourceUnitName ]) then
            def[tag] = config.footprintOverrides[ sourceUnitName ]
        else
            local oldValue = tonumber(def[tag])
            if (config.footprintConversions and config.footprintConversions[oldValue]) then
                def[tag] = config.footprintConversions[oldValue]
            else
                def[tag] = round(oldValue * mult)
            end
        end
    end
end

local function applyMultToVector(def, tag, mult)
    if (def[tag]) then
        local oldValues = def[tag]
        local newValues = {}
        for value in string_gmatch(oldValues, "%S+") do
            newValues[ #newValues + 1 ] = tonumber(value) * mult
        end
        def[tag] = table.concat(newValues, " ")
    end
end

local function applyMultToVectorAndRound(def, tag, mult)
    if (def[tag]) then
        local oldValues = def[tag]
        local newValues = {}
        for value in string_gmatch(oldValues, "%S+") do
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

local function scaleUnitDefMovementClass(ud, config)
    if (ud.movementclass) then
        local sourceUnitName = ud.customparams.sourceunit
        local convertedMoveClass

        if (config.moveClassOverrides and config.moveClassOverrides[ sourceUnitName ]) then
            convertedMoveClass = config.moveClassOverrides[ sourceUnitName ]
        else
            local moveClassName, moveClassSize = string_match(ud.movementclass, "(%a+)(%d+)")
            local convertedSize

            if (config.footprintOverrides and config.footprintOverrides[ sourceUnitName ]) then
                convertedSize = config.footprintOverrides[ sourceUnitName ]
            else
                moveClassSize = tonumber(moveClassSize)
                if (config.footprintConversions and config.footprintConversions[moveClassSize]) then
                    convertedSize = config.footprintConversions[moveClassSize]
                end
            end

            if (convertedSize) then
                convertedMoveClass = moveClassName .. convertedSize
            end
        end

        if (convertedMoveClass) then
            if (moveDefsByName[convertedMoveClass]) then
                ud.movementclass = convertedMoveClass
            else
                Spring.Echo("Missing converted movementClass: " .. convertedMoveClass, ud.unitname)
            end
        else
            Spring.Echo("No conversion found for movementClass: " .. ud.movementclass, ud.unitname)
        end
    end
end

local function scaleUnitDefYardMap (ud, multipliers, unscaledFootprintx, unscaledFootprintz)
    if (ud.yardmap) then
        if (multipliers.yardMapScale and multipliers.yardMapScale ~= 1) or
           (unscaledFootprintx ~= ud.footprintx) or
           (unscaledFootprintz ~= ud.footprintz) then
            local yardmap = string_gsub(ud.yardmap, " ", "")

            local yardmapLength = #yardmap
            local lineLength = unscaledFootprintx
            local numLines = unscaledFootprintz

            local yardMapScale = multipliers.yardMapScale or 1
            local highResolutionMult = (multipliers.yardMapToHighResolution and 2 or 1)
            local centerCharsToAdd = (ud.footprintx * highResolutionMult) - (unscaledFootprintx * yardMapScale)
            local centerLinesToAdd = (ud.footprintz * highResolutionMult) - (unscaledFootprintz * yardMapScale)

            local centerLine = math.floor((numLines - 1) / 2)
            local centerIndex = 1 + centerLine * lineLength

            local scaledYardMap = ""

            for i = 1, yardmapLength, lineLength do
                local lineEnd = math.min(i + lineLength - 1, yardmapLength)
                local lineCenter = i + math.floor((lineLength - 1) / 2)
                local scaledLine = ""

                for j = i, lineEnd do
                    local char = string_sub(yardmap, j, j)
                    local numCharRepeats = (j == lineCenter) and (yardMapScale + centerCharsToAdd) or yardMapScale
                    local scaledChar = string_rep(char, numCharRepeats)
                    scaledLine = scaledLine .. scaledChar
                end

                local numLineRepeats = (i == centerIndex) and (yardMapScale + centerLinesToAdd) or yardMapScale
                local multipliedLine = string_rep(scaledLine .. " ", numLineRepeats)
                scaledYardMap = scaledYardMap .. multipliedLine
            end

            ud.yardmap = string_sub(scaledYardMap, 1, -2)
        end
        if (multipliers.yardMapToHighResolution) then
            ud.yardmap = "h" .. ud.yardmap
        end
    end
end

local function applyUnitDefFeatureMults (ud, sizeMult, config)
    if (ud.featuredefs) then
        for _, fd in pairs(ud.featuredefs) do
            if not fd.customparams then
                fd.customparams = {}
            end

            fd.customparams.modelsizemult = sizeMult

            applyMultToVector(fd, "collisionvolumeoffsets", sizeMult)
            applyMultToVector(fd, "collisionvolumescales", sizeMult)
            applyMult(fd, "collisionspherescale", sizeMult)
            applyMultToFootprint(ud, fd, "footprintx", sizeMult, config)
            applyMultToFootprint(ud, fd, "footprintz", sizeMult, config)
        end
    end
end

local function applyUnitDefSizeMult (ud, multipliers, config)
    local sizeMult = multipliers.size

    ud.customparams.unitsizemult  = sizeMult
    ud.customparams.modelsizemult = sizeMult

    scaleUnitDefMovementClass(ud, config)

    -- footprint-related
    local unscaledFootprintx = ud.footprintx
    local unscaledFootprintz = ud.footprintz
    applyMultToFootprint(ud, ud, "footprintx", sizeMult, config)
    applyMultToFootprint(ud, ud, "footprintz", sizeMult, config)
    scaleUnitDefYardMap(ud, multipliers, unscaledFootprintx, unscaledFootprintz)

    applyMultToFootprint(ud, ud, "transportsize", sizeMult, config)
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

local explosionNamePrefix = [[custom:]]

local function processExplosionName (def, tag, withPrefix, config)
    if (def[tag]) then
        local prefixedExplosionName = lower(def[tag])
        local explosionName = prefixedExplosionName

        if (withPrefix) then
            if (prefixedExplosionName:sub(1, #explosionNamePrefix) == explosionNamePrefix) then
                explosionName = prefixedExplosionName:sub(#explosionNamePrefix + 1)
            else
                Spring.Echo("Explosion name without prefix:", prefixedExplosionName)
                return
            end
        end

        if (not excludedExplosionGenerators[ explosionName ]) then
            local configKey = config.explosionDefsConfigKey

            explosionDefVariants[configKey] = explosionDefVariants[configKey] or {}
            explosionDefVariants[configKey][explosionName] = true

            def[tag] = prefixedExplosionName .. config.explosionNamePostfix
        end
    end  
end

local function applyWeaponDefMults (wd, multipliers, config)
    if not wd.customparams then
        wd.customparams = {}
    end

    wd.customparams.weaponsize = config.weaponSizeValue

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

    local isBallistic =
        (wd.weapontype == "Cannon") -- other ballistic weapontypes don't support "myGravity" tag

    if (isBallistic) then
        local usesMapGravity = (not wd.mygravity) or (tonumber(wd.mygravity) == 0.0)

        if usesMapGravity then
            wd.mygravity = defaultMyGravity
        end

        applyMult(wd, "mygravity", 1.0 / multipliers.range) -- same trajectory shape at max range
    end

    if (wd.model and not excludedProjectileModels[ wd.model ]) then
        wd.customparams.modelsizemult = multipliers.projectileSize
    end
    applyMult(wd, "size", multipliers.projectileSize)
    applyMult(wd, "sizedecay", multipliers.projectileSize)
    applyMult(wd, "sizegrowth", multipliers.projectileSize) -- not used in ZK
    applyMult(wd, "collisionsize", multipliers.projectileSize) -- not used in ZK
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

    if (wd.customparams.spawns_name) then
        wd.customparams.spawns_name = wd.customparams.spawns_name .. config.unitNamePostfix
    end

    processExplosionName(wd, "cegtag", false, config)
    processExplosionName(wd, "explosiongenerator", true, config)
    processExplosionName(wd.customparams, "muzzleeffectfire", true, config)
    processExplosionName(wd.customparams, "misceffectfire", true, config)
end

local function processUnitDefWeaponName (ud, def, tag, config)
    if (def[tag]) then
        local weaponName = lower(def[tag])

        if not (ud.weapondefs and ud.weapondefs[weaponName]) then
            local configKey = config.externalWeaponDefsConfigKey

            externalWeaponDefVariants[configKey] = externalWeaponDefVariants[configKey] or {}
            externalWeaponDefVariants[configKey][weaponName] = true

            def[tag] = weaponName .. config.weaponNamePostfix
        end
    end  
end

local function applyUnitDefWeaponMults (ud, multipliers, config)
    if (ud.weapons) then
        for _, weaponData in pairs(ud.weapons) do
            processUnitDefWeaponName(ud, weaponData, "def", config)
        end
    end

    if (ud.weapondefs) then
        for _, wd in pairs(ud.weapondefs) do
            applyWeaponDefMults(wd, multipliers, config)
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

local function processUnitDefExplosions (ud, config)
    processUnitDefWeaponName(ud, ud, "explodeas", config)
    processUnitDefWeaponName(ud, ud, "selfdestructas", config)

    if (ud.sfxtypes and ud.sfxtypes.explosiongenerators) then
        local explosionGenerators = ud.sfxtypes.explosiongenerators

        for index = 1, #explosionGenerators do
            processExplosionName(explosionGenerators, index, true, config)
        end
    end
end

local function applyFactoryDefMultipliers (ud, multipliers, config)
    applyUnitDefSizeMult(ud, multipliers, config)
    applyUnitDefHealthMult (ud, multipliers.health)
    applyUnitDefResourceMults (ud, multipliers)
    applyUnitDefSensorMults (ud, multipliers)
    processUnitDefExplosions(ud, config)
end

local function applyUnitDefMultipliers (ud, multipliers, config)
    applyUnitDefCostMult(ud, multipliers.cost)
    applyUnitDefSizeMult(ud, multipliers, config)
    applyUnitDefHealthMult (ud, multipliers.health)
    applyUnitDefSpeedMult(ud, multipliers.speed)
    applyUnitDefResourceMults (ud, multipliers)
    applyUnitDefSensorMults (ud, multipliers)
    applyUnitDefSpecialAbilityMults (ud, multipliers)
    applyUnitDefWeaponMults(ud, multipliers, config)
    processUnitDefExplosions(ud, config)
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
        ud.customparams.parent_of_plate2 = ud.customparams.parent_of_plate
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

    if (ud.customparams.grey_goo_spawn) then
        ud.customparams.grey_goo_spawn = ud.customparams.grey_goo_spawn .. config.unitNamePostfix
    end

    applyUnitDefMultipliers(ud, config.multipliers, config)
end

local function processBuildOptions (buildoptions, includedSizesArray)
    local newBuildOptions = {}

    for _, unitName in ipairs (buildoptions) do
        if (not factoriesUnitsByName[unitName]) then -- retain order of static buildoptions
            newBuildOptions[ #newBuildOptions + 1 ] = unitName
        end
    end

    for _, unitSize in ipairs(includedSizesArray) do
        local unitNamePostfix = unitSizesConfig[unitSize].unitNamePostfix

        for _, unitName in ipairs (buildoptions) do
            if (factoriesUnitsByName[unitName]) then
                local unitNameWithPostfix = unitName .. unitNamePostfix
                if (UnitDefs[unitNameWithPostfix]) then
                    newBuildOptions[ #newBuildOptions + 1 ] = unitNameWithPostfix
                end
            end
        end
    end

    return newBuildOptions
end

local function addSizedBuildOptions (buildoptions, includedBuildOption, includedSizesArray)
    local newBuildOptions = {}

    for _, unitName in ipairs (buildoptions) do
        if (unitName == includedBuildOption) then
            for _, unitSize in ipairs(includedSizesArray) do
                local unitNamePostfix = unitSizesConfig[unitSize].unitNamePostfix
                newBuildOptions[ #newBuildOptions + 1 ] = unitName .. unitNamePostfix
            end
        else
            newBuildOptions[ #newBuildOptions + 1 ] = unitName
        end
    end

    return newBuildOptions
end

for _, ud in pairs (UnitDefs) do  -- Replace buildoptions
    if (buildOptionReplacements[ ud.unitname ]) then
        local replacementsArray = buildOptionReplacements[ ud.unitname ]

        for _, replacementData in ipairs (replacementsArray) do
            ud.buildoptions = addSizedBuildOptions(ud.buildoptions, replacementData.buildOption, replacementData.replacementSizes)
        end
    end
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

            if (ud.customparams.child_of_factory) then
                ud.customparams.child_of_factory2 = largeUd.customparams.child_of_factory
            end

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

GlobalShared = GlobalShared or {}

GlobalShared.applyWeaponDefMults = applyWeaponDefMults
GlobalShared.externalWeaponDefVariants = externalWeaponDefVariants

GlobalShared.explosionDefVariants = explosionDefVariants
