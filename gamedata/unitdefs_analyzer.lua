Spring.Echo("UnitDefs Analyzer")

local unitNameAndCost = {}

for _, ud in pairs (UnitDefs) do
    unitNameAndCost[ #unitNameAndCost + 1 ] = {
        name = ud.name,
        cost = ud.buildcostmetal
    }
end

table.sort(unitNameAndCost, function(a, b) return (a.cost < b.cost) end)

--Spring.Echo("Units by cost:")
--Spring.Utilities.TableEcho(unitNameAndCost, "unitNameAndCost")

local foundUnitDefTags = {
    customparams = {},
    weapons = {},
    weapondefs = {
        customparams = {},
        damage = {},
    },
    featuredefs = {},
}

local exampleUnitDefValues = {
    customparams = {},
    weapons = {},
    weapondefs = {
        customparams = {},
        damage = {},
    },
    featuredefs = {},
}

local function analyzeValues (values, foundTags, exampleValues)
    if (values) then
        for tag, value in pairs(values) do
            if (not foundTags[tag]) then
                foundTags[tag] = true
                exampleValues[tag] = value
            end
        end
    end
end

for _, ud in pairs (UnitDefs) do
    analyzeValues (ud, foundUnitDefTags, exampleUnitDefValues)
    analyzeValues (ud.customparams, foundUnitDefTags.customparams, exampleUnitDefValues.customparams)
    if (ud.weapons) then
        for key, values in pairs(ud.weapons) do
            analyzeValues (values, foundUnitDefTags.weapons, exampleUnitDefValues.weapons)
        end
    end
    if (ud.weapondefs) then
        for key, values in pairs(ud.weapondefs) do
            analyzeValues (values, foundUnitDefTags.weapondefs, exampleUnitDefValues.weapondefs)
            analyzeValues (values.customparams, foundUnitDefTags.weapondefs.customparams, exampleUnitDefValues.weapondefs.customparams)
            analyzeValues (values.damage, foundUnitDefTags.weapondefs.damage, exampleUnitDefValues.weapondefs.damage)
        end
    end
    if (ud.featuredefs) then
        for key, values in pairs(ud.featuredefs) do
            analyzeValues (values, foundUnitDefTags.featuredefs, exampleUnitDefValues.featuredefs)
        end
    end
end

--Spring.Utilities.TableEcho(exampleUnitDefValues, "exampleUnitDefValues")
