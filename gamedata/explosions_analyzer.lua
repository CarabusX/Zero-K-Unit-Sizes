Spring.Echo("ExplosionDefs Analyzer")

local foundExplosionDefTags = {
    spawner = {
        properties = {},
    },
}

local exampleExplosionDefValues = {
    spawner = {
        properties = {},
    },
}

local function analyzeSingleValue (tag, value, foundTags, exampleValues)
    if (not foundTags[tag]) then
        foundTags[tag] = true
        exampleValues[tag] = value
    end
end

local function analyzeValues (values, foundTags, exampleValues)
    if (values) then
        for tag, value in pairs(values) do
            analyzeSingleValue(tag, value, foundTags, exampleValues)
        end
    end
end

for _, explosionDef in pairs (ExplosionDefs) do
    for spawnerName, spawnerDef in pairs(explosionDef) do
        if (type(spawnerDef) == 'table') then
            analyzeValues (spawnerDef, foundExplosionDefTags.spawner, exampleExplosionDefValues.spawner)
            analyzeValues (spawnerDef.properties, foundExplosionDefTags.spawner.properties, exampleExplosionDefValues.spawner.properties)
        else
            analyzeSingleValue(spawnerName, spawnerDef, foundExplosionDefTags, exampleExplosionDefValues)
        end
    end
end

--Spring.Utilities.TableEcho(exampleExplosionDefValues, "exampleExplosionDefValues")
