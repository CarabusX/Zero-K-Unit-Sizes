Spring.Echo("Loading ExplosionDefs_mod")

--VFS.Include('gamedata/explosions_analyzer.lua', nil, VFS.GAME)

local unitSizesConfig = VFS.Include("gamedata/Configs/unitsizes_config.lua", nil, VFS.GAME)
local explosionDefVariants = VFS.Include("gamedata/explosions_variants.lua", nil, VFS.GAME)

VFS.Include("LuaRules/Utilities/tablefunctions.lua")
local CopyTable = Spring.Utilities.CopyTable

local lower = string.lower

--------------------------------------------------------------------------------

local function ArrayToSet (array)
    local set = {}
    for _, value in ipairs (array) do
        set[value] = true
    end
    return set
end

--------------------------------------------------------------------------------

local function createMultFunction(mult)
    return function (value)
        return tonumber(value) * mult
    end
end

local function multiplyCegValues(values, multFunc)
    local result, numMatches = string.gsub(values, "%-?%d*%.?%d+", multFunc)
    --if (numMatches == 0) then
    --    Spring.Echo("No numbers matched in value:", values)
    --end
    return result
end

local function multiplyCegValuesVector(vector, multFunc)
    local result, numMatches = string.gsub(vector, "[^,]+", function(values)
        return multiplyCegValues(values, multFunc)
    end)
    --if (numMatches == 0) then
    --    Spring.Echo("No coordinates matched in vector:", vector)
    --end
    return result
end

local function applyMult(def, tag, multFunc)
    if (def[tag]) then
        def[tag] = multiplyCegValues(def[tag], multFunc)
    end
end

local function applyMultToVector(def, tag, multFunc)
    if (def[tag]) then
        def[tag] = multiplyCegValuesVector(def[tag], multFunc)
    end
end

local function applySpawnerDefMults (sd, config)
    local sizeMult     = config.multipliers.projectileSize
    local sizeMultFunc = createMultFunction(sizeMult)

    applyMult(sd, "circlesize", sizeMultFunc)
    applyMult(sd, "circlegrowth", sizeMultFunc)
    applyMult(sd, "flashsize", sizeMultFunc)

    if (sd.properties) then
        applyMultToVector(sd.properties, "pos", sizeMultFunc)
        applyMultToVector(sd.properties, "speed", sizeMultFunc)
        applyMult(sd.properties, "size", sizeMultFunc)
        applyMult(sd.properties, "startsize", sizeMultFunc)

        -- for CBitmapMuzzleFlame class "sizegrowth" tag is relative 
        -- for all other classes it is absolute so it should be scaled by sizeMult
        if (sd.class ~= [[CBitmapMuzzleFlame]]) then
            applyMult(sd.properties, "sizegrowth", sizeMultFunc)
        end

        applyMult(sd.properties, "sizeexpansion", sizeMultFunc)
        applyMult(sd.properties, "expansionspeed", sizeMultFunc)
        applyMult(sd.properties, "length", sizeMultFunc)
        applyMult(sd.properties, "lengthgrowth", sizeMultFunc)
        applyMult(sd.properties, "width", sizeMultFunc)
        applyMult(sd.properties, "particlesize", sizeMultFunc)
        applyMult(sd.properties, "particlesizespread", sizeMultFunc)
        applyMult(sd.properties, "particlespeed", sizeMultFunc)
        applyMult(sd.properties, "particlespeedspread", sizeMultFunc)
        applyMultToVector(sd.properties, "gravity", sizeMultFunc)
        applyMultToVector(sd.properties, "wantedpos", sizeMultFunc)
    end
end

local explosionNamesList
local explosionNamesSet

local explosionNamePrefix = [[custom:]]

local function processExplosionName (def, tag, config)
    if (def[tag]) then
        local prefixedExplosionName = lower(def[tag])

        if (prefixedExplosionName:sub(1, #explosionNamePrefix) == explosionNamePrefix) then
            local explosionName = prefixedExplosionName:sub(#explosionNamePrefix + 1)

            if (not explosionNamesSet[explosionName]) then
                explosionNamesSet[explosionName] = true
                explosionNamesList[ #explosionNamesList + 1 ] = explosionName
            end

            def[tag] = prefixedExplosionName .. config.explosionNamePostfix
        else
            Spring.Echo("Explosion name without prefix:", prefixedExplosionName)
        end
    end 
end

local function ProcessExplosionSpawners (explosionDef, config)
    for spawnerName, spawnerDef in pairs(explosionDef) do
        if (type(spawnerDef) == 'table') then
            applySpawnerDefMults (spawnerDef, config)

            if (spawnerDef.class == [[CExpGenSpawner]] and spawnerDef.properties) then
                processExplosionName (spawnerDef.properties, "explosiongenerator", config)
            end
        end
    end
end

local newExplosionDefs = {}

local function ProcessExplosionDef (explosionName, config)
    local explosionDef = ExplosionDefs[explosionName]

    if (explosionDef) then
        local sizedEd = CopyTable(explosionDef, true)
        local sizedExplosionName = explosionName .. config.explosionNamePostfix

        ProcessExplosionSpawners(sizedEd, config)

        newExplosionDefs[ sizedExplosionName ] = sizedEd
    else
        Spring.Echo("Explosion def not found:", explosionName)
    end
end

for configKey, _explosionNamesList in pairs(explosionDefVariants) do
    local config = unitSizesConfig[configKey]

    explosionNamesList = _explosionNamesList
    explosionNamesSet  = ArrayToSet(explosionNamesList)

    for _, explosionName in ipairs(explosionNamesList) do  -- elements can be added to explosionNamesList during iteration
        ProcessExplosionDef (explosionName, config)
    end
end

CopyTable(newExplosionDefs, false, ExplosionDefs)

--Spring.Utilities.TableEcho(ExplosionDefs, "ExplosionDefs modified")
