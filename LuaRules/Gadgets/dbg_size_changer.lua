--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if not gadgetHandler:IsSyncedCode() then
	return
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Size Changer",
		desc      = "Changes the sizes of units.",
		author    = "GoogleFrog, Rafal[ZK]",
		date      = "10 April 2020",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local spGetUnitPieceList = Spring.GetUnitPieceList
local spGetUnitPieceInfo = Spring.GetUnitPieceInfo
local spGetUnitPieceMatrix = Spring.GetUnitPieceMatrix

local spSetUnitPieceMatrix = Spring.SetUnitPieceMatrix

--------------------------------------------------------------------------------

local NULL_PIECE = "[null]"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function SetScale(unitID, base, scale)
	local p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16 = spGetUnitPieceMatrix(unitID, base)
	local pieceTable = {p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16}

	--Spring.Echo(p1, p2, p3, p4)
	--Spring.Echo(p5, p6, p7, p8)
	--Spring.Echo(p9, p10, p11, p12)
	--Spring.Echo(p13, p14, p15, p16)

	pieceTable[1] = pieceTable[1] * scale
	pieceTable[2] = pieceTable[2] * scale
	pieceTable[3] = pieceTable[3] * scale

	pieceTable[5] = pieceTable[5] * scale
	pieceTable[6] = pieceTable[6] * scale
	pieceTable[7] = pieceTable[7] * scale

	pieceTable[9] = pieceTable[9] * scale
	pieceTable[10] = pieceTable[10] * scale
	pieceTable[11] = pieceTable[11] * scale

	pieceTable[13] = pieceTable[13] * scale
	pieceTable[14] = pieceTable[14] * scale
	pieceTable[15] = pieceTable[15] * scale

	spSetUnitPieceMatrix(unitID, base, pieceTable)
end

local function FindBase(unitID)
	local pieces = spGetUnitPieceList(unitID)
	for pieceNum = 1, #pieces do
		local pieceInfo = spGetUnitPieceInfo(unitID, pieceNum)
		if (pieceInfo.parent == NULL_PIECE) then
			return pieceNum
		end
	end
end

GG.SetUnitScale = function (unitID, scale)
	local base = FindBase(unitID)
	if base then
		SetScale(unitID, base, scale)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	local ud = UnitDefs[unitDefID]

	if (ud.customParams.modelsizemult and ud.customParams.modelsizemult ~= 1.0) then
		GG.SetUnitScale(unitID, ud.customParams.modelsizemult)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
