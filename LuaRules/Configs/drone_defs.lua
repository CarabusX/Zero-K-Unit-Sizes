-- reloadTime is in seconds
-- offsets = {x,y,z} , where x is left(-)/right(+), y is up(+)/down(-), z is forward(+)/backward(-)
local DRONES_COST_RESOURCES = false

local carrierDefs = {}

local carrierDefNames = {

	shipcarrier = {
		spawnPieces = {"DroneAft", "DroneFore", "DroneLower","DroneUpper"},
		{
			drone = UnitDefNames.dronecarry.id,
			reloadTime = 5,
			maxDrones = 8,
			spawnSize = 1,
			range = 1000,
			maxChaseRange = 1500,
			buildTime = 25,
			maxBuild = 4,
			offsets = {0, 0, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
		},
	},
	--gunshipkrow = { {drone = UnitDefNames.dronelight.id, reloadTime = 15, maxDrones = 6, spawnSize = 2, range = 900, buildTime=3,
	-- offsets = {0,0,0,colvolMidX=0, colvolMidY=0,colvolMidZ=0,aimX=0,aimY=0,aimZ=0}},
	nebula = {
		spawnPieces = {"pad1", "pad2", "pad3", "pad4"},
		{
			drone = UnitDefNames.dronefighter.id,
			reloadTime = 15,
			maxDrones = 8,
			spawnSize = 2,
			range = 1000,
			maxChaseRange = 1500,
			buildTime = 3,
			maxBuild = 4,
			offsets = {0, 8, 15, colvolMidX = 0, colvolMidY = 30, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0} --shift colvol to avoid collision.
		},
	},
	pw_garrison = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.dronelight.id,
			reloadTime = 10,
			maxDrones = 8,
			spawnSize = 1,
			range = 800,
			maxChaseRange = 1300,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 3, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
		},
	},
	pw_grid = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.droneheavyslow.id,
			reloadTime = 10,
			maxDrones = 6,
			spawnSize = 1,
			range = 800,
			maxChaseRange = 1300,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 5, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
		},
	},
	pw_hq_attacker = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.dronelight.id,
			reloadTime = 10,
			maxDrones = 6,
			spawnSize = 1,
			range = 500,
			maxChaseRange = 1200,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 3, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
		},
	},
	pw_hq_defender = {
		spawnPieces = {"drone"},
		{
			drone = UnitDefNames.dronelight.id,
			reloadTime = 10,
			maxDrones = 6,
			spawnSize = 1,
			range = 600,
			maxChaseRange = 1200,
			buildTime = 5,
			maxBuild = 1,
			offsets = {0, 3, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
		},
	},
}

local presets = {
	module_companion_drone = {
		drone = UnitDefNames.dronelight.id,
		reloadTime = 12,
		maxDrones = 2,
		spawnSize = 1,
		range = 600,
		maxChaseRange = 1200,
		buildTime = 6,
		maxBuild = 1,
		offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
	},
	module_battle_drone = {
		drone = UnitDefNames.droneheavyslow.id,
		reloadTime = 18,
		maxDrones = 1,
		spawnSize = 1,
		range = 600,
		maxChaseRange = 1200,
		buildTime = 9,
		maxBuild = 1,
		offsets = {0, 35, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
	},
}

local unitRulesCarrierDefs = {
	drone = {
		drone = UnitDefNames.dronelight.id,
		reloadTime = 12,
		maxDrones = 2,
		spawnSize = 1,
		range = 600,
		maxChaseRange = 1200,
		buildTime = 10,
		maxBuild = 1,
		offsets = {0, 50, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
	},
	droneheavyslow = {
		drone = UnitDefNames.droneheavyslow.id,
		reloadTime = 18,
		maxDrones = 1,
		spawnSize = 1,
		range = 600,
		maxChaseRange = 1200,
		buildTime = 15,
		maxBuild = 1,
		offsets = {0, 50, 0, colvolMidX = 0, colvolMidY = 0, colvolMidZ = 0, aimX = 0, aimY = 0, aimZ = 0}
	}
}

-- modified in mod -- BEGIN
local unitSizesConfig = VFS.Include("gamedata/Configs/unitsizes_config.lua", nil, VFS.GAME)

local function applyDroneOffsetsMult (offsets, sizeMult)
	offsets[1] = offsets[1] * sizeMult
	offsets[2] = offsets[2] * sizeMult
	offsets[3] = offsets[3] * sizeMult
	offsets.colvolMidX = offsets.colvolMidX * sizeMult
	offsets.colvolMidY = offsets.colvolMidY * sizeMult
	offsets.colvolMidZ = offsets.colvolMidZ * sizeMult
	offsets.aimX = offsets.aimX * sizeMult
	offsets.aimY = offsets.aimY * sizeMult
	offsets.aimZ = offsets.aimZ * sizeMult
end

local function applyCarrierDefSizeConfig (unitName, config)
	local sourceCarrierData = carrierDefNames[unitName]
	local carrierData = Spring.Utilities.CopyTable(sourceCarrierData, true)

	for i = 1, #carrierData do
		local droneData = carrierData[i]
		local droneUd = UnitDefs[ droneData.drone ]
		local sizedDroneUd = UnitDefNames[ droneUd.name .. config.unitNamePostfix ]

		if (sizedDroneUd) then
			droneData.drone = sizedDroneUd.id
			applyDroneOffsetsMult(droneData.offsets, config.multipliers.size)
		end

		droneData.range = droneData.range * config.multipliers.range
		droneData.maxChaseRange = droneData.maxChaseRange * config.multipliers.range
	end
	
	carrierDefNames[ unitName .. config.unitNamePostfix ] = carrierData
end

local function CreateSizedCarrierDefs(unitName)
	applyCarrierDefSizeConfig (unitName, unitSizesConfig.small)
	applyCarrierDefSizeConfig (unitName, unitSizesConfig.large)
end

CreateSizedCarrierDefs("shipcarrier")
-- modified in mod -- END

--[[
for name, ud in pairs(UnitDefNames) do
	if ud.customParams.sheath_preset then
		sheathDefNames[name] = Spring.Utilities.CopyTable(presets[ud.customParams.sheath_preset], true)
	end
end
]]--
for id, ud in pairs(UnitDefs) do
	if ud.customParams and ud.customParams.drones then
		local droneFunc = loadstring("return "..ud.customParams.drones)
		local drones = droneFunc()
		carrierDefs[id] = {}
		for i=1,#drones do
			carrierDefs[id][i] = Spring.Utilities.CopyTable(presets[drones[i]])
		end
	end
end

for name, data in pairs(carrierDefNames) do
	if UnitDefNames[name] then
		carrierDefs[UnitDefNames[name].id] = data
	end
end

local thingsWhichAreDrones = {
	[UnitDefNames.dronecarry.id] = true,
	[UnitDefNames.dronelight.id] = true,
	[UnitDefNames.droneheavyslow.id] = true,
	[UnitDefNames.dronefighter.id] = true
}

-- modified in mod -- BEGIN
local function AddSizedThingsWhichAreDrones(droneUnitName)
	local smallDroneUd = UnitDefNames[ droneUnitName .. unitSizesConfig.small.unitNamePostfix ]
	local largeDroneUd = UnitDefNames[ droneUnitName .. unitSizesConfig.large.unitNamePostfix ]

	if (smallDroneUd) then
		thingsWhichAreDrones[ smallDroneUd.id ] = true
	end
	if (largeDroneUd) then
		thingsWhichAreDrones[ largeDroneUd.id ] = true
	end
end

AddSizedThingsWhichAreDrones("dronecarry")
-- modified in mod -- END

local function ProcessCarrierDef(carrierData)
	local ud = UnitDefs[carrierData.drone]
	-- derived from: time_to_complete = (1.0/build_step_fraction)*build_interval
	local buildUpProgress = 1/(carrierData.buildTime)*(1/30)
	carrierData.buildStep = buildUpProgress
	carrierData.buildStepHealth = buildUpProgress*ud.health
	
	if DRONES_COST_RESOURCES then
		carrierData.buildCost = ud.metalCost
		carrierData.buildStepCost = buildUpProgress*carrierData.buildCost
		carrierData.perSecondCost = carrierData.buildCost/carrierData.buildTime
	end
	
	carrierData.colvolTweaked = carrierData.offsets.colvolMidX ~= 0 or carrierData.offsets.colvolMidY ~= 0
									or carrierData.offsets.colvolMidZ ~= 0 or carrierData.offsets.aimX ~= 0
										or carrierData.offsets.aimY ~= 0 or carrierData.offsets.aimZ ~= 0
	return carrierData
end

for name, carrierData in pairs(carrierDefs) do
	for i = 1, #carrierData do
		carrierData[i] = ProcessCarrierDef(carrierData[i])
	end
end

for name, carrierData in pairs(unitRulesCarrierDefs) do
	carrierData = ProcessCarrierDef(carrierData)
end

return carrierDefs, thingsWhichAreDrones, unitRulesCarrierDefs
