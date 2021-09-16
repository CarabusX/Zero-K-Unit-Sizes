--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Projectile Size Changer",
		desc      = "Changes the sizes of projectiles.",
		author    = "Rafal[ZK]",
		date      = "September 2020",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------

local scSetWatchWeapon     = Script.SetWatchWeapon
local spGetProjectileDefID = Spring.GetProjectileDefID

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

for weaponDefID, wd in ipairs(WeaponDefs) do
	if (wd.customParams.modelsizemult and wd.customParams.modelsizemult ~= 1.0) then
		scSetWatchWeapon(weaponDefID, true)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local scaledProjectilesById = {}

function gadget:ProjectileCreated(projectileID, ownerID, weaponDefID)
	if (not weaponDefID) then
		weaponDefID = spGetProjectileDefID(projectileID)

		if (not weaponDefID) then
			return
		end
	end

	local wd = WeaponDefs[weaponDefID]
	local scale = wd.customParams.modelsizemult

	if (scale and scale ~= 1.0) then
		scaledProjectilesById[projectileID] = true
		SendToUnsynced("SetProjectileModelScale", projectileID, scale)
	end
end

function gadget:ProjectileDestroyed(projectileID)
	if (scaledProjectilesById[projectileID]) then
		scaledProjectilesById[projectileID] = nil
		SendToUnsynced("SetProjectileModelScale", projectileID, false)
	end
end

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------

local spURSetProjectileLuaDraw = Spring.UnitRendering.SetProjectileLuaDraw
local glScale = gl.Scale

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local projectileScalesById = {}

local function SetProjectileModelScale(_, projectileID, scale)
	if (scale) then
		projectileScalesById[projectileID] = scale
		spURSetProjectileLuaDraw(projectileID, true)
	else
		projectileScalesById[projectileID] = nil
		spURSetProjectileLuaDraw(projectileID, false)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SetProjectileModelScale", SetProjectileModelScale)
end

function gadget:Shutdown()
	gadgetHandler.RemoveSyncAction("SetProjectileModelScale")
end

function gadget:DrawProjectile(projectileID, drawMode)
	local scale = projectileScalesById[projectileID]

	if (scale) then
		glScale(scale, scale, scale)
	end

	return false
end

--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
end
