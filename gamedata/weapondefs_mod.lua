Spring.Echo("Loading WeaponDefs_mod")

local unitSizesConfig = VFS.Include("gamedata/Configs/unitsizes_config.lua", nil, VFS.GAME)

VFS.Include("LuaRules/Utilities/tablefunctions.lua")
local CopyTable = Spring.Utilities.CopyTable

local applyWeaponDefMults       = GlobalShared.applyWeaponDefMults
local externalWeaponDefVariants = GlobalShared.externalWeaponDefVariants

--------------------------------------------------------------------------------

local newWeaponDefs = {}

for configKey, externalWeaponDefNames in pairs(externalWeaponDefVariants) do
    local config = unitSizesConfig[configKey]

    for weaponName, wd in pairs (WeaponDefs) do
        if (externalWeaponDefNames[weaponName]) then
            if (not wd.customparams) then
                wd.customparams = {}
            end

            wd.customparams.sourceweapon = weaponName

            local sizedWd = CopyTable(wd, true)
            local sizedWeaponName = weaponName .. config.weaponNamePostfix
            applyWeaponDefMults(sizedWd, config.multipliers, config)
            newWeaponDefs[ sizedWeaponName ] = sizedWd
        end
    end
end

CopyTable(newWeaponDefs, false, WeaponDefs)

--Spring.Utilities.TableEcho(WeaponDefs, "WeaponDefs modified")
