-- $Id: movedefs.lua 3518 2008-12-23 08:46:54Z saktoth $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    moveDefs.lua
--  brief:   move data definitions
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local common_depthmodparams = {
	quadraticCoeff = 0.0027,
	linearCoeff = 0.02,
}

local moveDefs = {

	SKBOT2 = { -- Small
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 16,
		maxslope = 36,
		crushstrength = 5,
		depthmodparams = common_depthmodparams,
	},
	
	KBOT2 = {
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 22,
		maxslope = 36,
		crushstrength = 50,
		depthmodparams = common_depthmodparams,
	},

	KBOT3 = {
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 22,
		maxslope = 36,
		crushstrength = 150,
		depthmodparams = common_depthmodparams,
	},
	
	KBOT4 = {
		footprintx = 4,
		footprintz = 4,
		maxwaterdepth = 22,
		maxslope = 36,
		crushstrength = 500,
		depthmodparams = common_depthmodparams,
	},

	KBOT5 = { -- fake to recalculate path cache
		footprintx = 5,
		footprintz = 5,
		maxwaterdepth = 123,
		maxslope = 36,
		crushstrength = 999,
		depthmodparams = common_depthmodparams,
	},
	
	AKBOT2 = {		--amphib
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 5000,
		depthmod = 0,
		maxslope = 36,
		crushstrength = 50,
	},
	
	AKBOT3 = {		--amphib
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 5000,
		depthmod = 0,
		maxslope = 36,
		crushstrength = 150,
	},
	
	AKBOT4 = {		--amphib
		footprintx = 4,
		footprintz = 4,
		maxwaterdepth = 5000,
		depthmod = 0,
		maxslope = 36,
		crushstrength = 500,
	},
	
	TKBOT2 = {		--allterrain
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 16,
		maxslope = 70,
		crushstrength = 5,
		depthmodparams = common_depthmodparams,
	},

	TKBOT3 = {		--allterrain
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 22,
		maxslope = 70,
		crushstrength = 150,
		depthmodparams = common_depthmodparams,
	},
	
	TKBOT4 = {		--allterrain
		footprintx = 4,
		footprintz = 4,
		maxwaterdepth = 22,
		maxslope = 70,
		crushstrength = 500,
		depthmodparams = common_depthmodparams,
	},

	ATKBOT3 = {		--amphib + allterrain
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 5000,
		maxslope = 70,
		depthmod = 0,
		crushstrength = 150,
	},
	
	TANK2 = {
		footprintx = 2,
		footprintz = 2,
		maxwaterdepth = 22,
		maxslope = 18,
		slopemod = 20,
		crushstrength = 50,
		depthmodparams = common_depthmodparams,
	},
	
	TANK3 = {
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 22,
		maxslope = 18,
		slopemod = 20,
		crushstrength = 150,
		depthmodparams = common_depthmodparams,
	},

	TANK4 = {
		footprintx = 4,
		footprintz = 4,
		maxwaterdepth = 22,
		maxslope = 18,
		slopemod = 20,
		crushstrength = 500,
		depthmodparams = common_depthmodparams,
	},
	
	HOVER2 = {
		footprintx = 2,
		footprintz = 2,
		maxslope = 18,
		maxwaterdepth = 5000,
		slopemod = 40,
		crushstrength = 50,
	},
	HOVER3 = {
		footprintx = 3,
		footprintz = 3,
		maxslope = 18,
		maxwaterdepth = 5000,
		slopemod = 40,
		crushstrength = 50,
	},
	HOVER4 = {
		footprintx = 4,
		footprintz = 4,
		maxslope = 18,
		maxwaterdepth = 5000,
		slopemod = 40,
		crushstrength = 50,
	},

	BHOVER5 = { --for white dragons
		footprintx = 5,
		footprintz = 5,
		maxslope = 36,
		maxwaterdepth = 5000,
		crushstrength = 150,
	},

	BHOVER3 = {		--hover with bot slope
		footprintx = 3,
		footprintz = 3,
		maxslope = 36,
		maxwaterdepth = 5000,
		--slopemod = 60,
		crushstrength = 150,
	},

	BOAT3 = {
		footprintx = 3,
		footprintz = 3,
		minwaterdepth = 5,
		crushstrength = 150,
	},

	BOAT4 = {
		footprintx = 4,
		footprintz = 4,
		minwaterdepth = 5,
		crushstrength = 500,
	},
	
	BOAT5 = {
		footprintx = 5,
		footprintz = 5,
		minwaterdepth = 15,
		crushstrength = 5000,
	},
	
	UBOAT3 = {
		footprintx = 3,
		footprintz = 3,
		minwaterdepth = 15,
		crushstrength = 150,
		subMarine = 1,
	},

	-- modified in mod -- BEGIN	
	SKBOT3 = { -- Small
		footprintx = 3,
		footprintz = 3,
		maxwaterdepth = 16,
		maxslope = 36,
		crushstrength = 15,
		depthmodparams = common_depthmodparams,
	},

	KBOT6 = {
		footprintx = 6,
		footprintz = 6,
		maxwaterdepth = 22,
		maxslope = 36,
		crushstrength = 1500,
		depthmodparams = common_depthmodparams,
	},
	
	AKBOT6 = {		--amphib
		footprintx = 6,
		footprintz = 6,
		maxwaterdepth = 5000,
		depthmod = 0,
		maxslope = 36,
		crushstrength = 1500,
	},
	
	TKBOT6 = {		--allterrain
		footprintx = 6,
		footprintz = 6,
		maxwaterdepth = 22,
		maxslope = 70,
		crushstrength = 1500,
		depthmodparams = common_depthmodparams,
	},

	TANK6 = {
		footprintx = 6,
		footprintz = 6,
		maxwaterdepth = 22,
		maxslope = 18,
		slopemod = 20,
		crushstrength = 1500,
		depthmodparams = common_depthmodparams,
	},

	HOVER6 = {
		footprintx = 6,
		footprintz = 6,
		maxslope = 18,
		maxwaterdepth = 5000,
		slopemod = 40,
		crushstrength = 50,
	},

	BOAT2 = {
		footprintx = 2,
		footprintz = 2,
		minwaterdepth = 5,
		crushstrength = 50,
	},

	BOAT6 = {
		footprintx = 6,
		footprintz = 6,
		minwaterdepth = 5,
		crushstrength = 1500,
	},

	BOAT7 = {
		footprintx = 7,
		footprintz = 7,
		minwaterdepth = 15,
		crushstrength = 5000,
	},

	UBOAT4 = {
		footprintx = 4,
		footprintz = 4,
		minwaterdepth = 15,
		crushstrength = 500,
		subMarine = 1,
	},
	-- modified in mod -- END
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- convert from map format to the expected array format

local array = {}
local i = 1
for k,v in pairs(moveDefs) do
	v.heatmapping = false -- disable heatmapping
	v.allowRawMovement = true
	array[i] = v
	v.name = k
	i = i + 1
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return array

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
