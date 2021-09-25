local VFS = VFS
local vfsInclude = VFS.Include
local vfsDirList = VFS.DirList

local system = vfsInclude('gamedata/system.lua')
local lowerkeys = system.lowerkeys

vfsInclude("LuaRules/Utilities/tablefunctions.lua")
local suCopyTable = Spring.Utilities.CopyTable

local files = vfsDirList("effects", "*.lua")
suCopyTable(vfsDirList("gamedata/explosions", "*.lua", VFS.MAP), false, files)

local shared = {} -- shared amongst the lua explosiondef enviroments

local explosionDefs = {}
for i = 1, #files do
	suCopyTable(lowerkeys(vfsInclude(files[i])), false, explosionDefs)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[ This lets mutators add a bit of explosions_post processing without
     losing access to future gameside updates to explosions_post. ]]
local MODSIDE_POSTS_FILEPATH = 'gamedata/explosions_mod.lua'
if VFS.FileExists(MODSIDE_POSTS_FILEPATH, VFS.GAME) then
	Shared = shared  -- make it global
	ExplosionDefs = explosionDefs  -- make it global
	vfsInclude(MODSIDE_POSTS_FILEPATH, nil, VFS.GAME)
	ExplosionDefs = nil
  	Shared = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

for edName, eDef in pairs(explosionDefs) do
	for fxName, fxDef in pairs(eDef) do
		if(type(fxDef) == 'table') then
			if fxDef.ground and fxDef.voidground == nil then
				fxDef.voidground = true
			end
		end
	end
end

return explosionDefs
