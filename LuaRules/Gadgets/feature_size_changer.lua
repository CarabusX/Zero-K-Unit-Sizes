--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Feature Size Changer",
		desc      = "Changes the sizes of features.",
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

local spGetFeatureDefID = Spring.GetFeatureDefID

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local scaledFeaturesById = {}

function gadget:FeatureCreated(featureID, allyTeamID)
	local featureDefID = spGetFeatureDefID(featureID)
	local fd = FeatureDefs[featureDefID]
	local scale = fd.customParams.modelsizemult

	if (scale and scale ~= 1.0) then
		scaledFeaturesById[featureID] = true
		SendToUnsynced("SetFeatureModelScale", featureID, scale)
	end
end

function gadget:FeatureDestroyed(featureID, allyTeamID)
	if (scaledFeaturesById[featureID]) then
		scaledFeaturesById[featureID] = nil
		SendToUnsynced("SetFeatureModelScale", featureID, false)
	end
end

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------

local spFRSetFeatureLuaDraw = Spring.FeatureRendering.SetFeatureLuaDraw
local glScale = gl.Scale

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local featureScalesById = {}

local function SetFeatureModelScale(_, featureID, scale)
	if (scale) then
		featureScalesById[featureID] = scale
		spFRSetFeatureLuaDraw(featureID, true)
	else
		featureScalesById[featureID] = nil
		spFRSetFeatureLuaDraw(featureID, false)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("SetFeatureModelScale", SetFeatureModelScale)
end

function gadget:Shutdown()
	gadgetHandler.RemoveSyncAction("SetFeatureModelScale")
end

function gadget:DrawFeature(featureID, drawMode)
	local scale = featureScalesById[featureID]

	if (scale) then
		glScale(scale, scale, scale)
	end

	return false
end

--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
end
