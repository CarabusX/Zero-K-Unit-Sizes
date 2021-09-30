--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Unit BuildPics Size Icons",
		desc      = "Generates buildpics with size icons for sized variants of units.",
		author    = "Rafal[ZK]",
		date      = "September 2020",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = false,  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then
    return false
end

--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------

local glTexture          = gl.Texture
local glTextureInfo      = gl.TextureInfo
local glCreateTexture    = gl.CreateTexture
local glRenderToTexture  = gl.RenderToTexture
local glDeleteTexture    = gl.DeleteTexture
local glDeleteTextureFBO = gl.DeleteTextureFBO
local glTexRect          = gl.TexRect
local glSaveImage        = gl.SaveImage
local glBlending         = gl.Blending
local glMatrixMode       = gl.MatrixMode
local glPushMatrix       = gl.PushMatrix
local glPopMatrix        = gl.PopMatrix
local glTranslate        = gl.Translate
local glScale            = gl.Scale

local GL_TEXTURE   = GL.TEXTURE
local GL_MODELVIEW = GL.MODELVIEW

local GL_RGBA = 0x1908

local string_match = string.match

--------------------------------------------------------------------------------
-- CONFIG

local unitSizesConfig = VFS.Include("gamedata/Configs/unitsizes_config.lua", nil, VFS.GAME)

local sizeIconsConfig = {
    fontPath = "fonts/FreeSansBold.otf",
    fontSize = 20,
    fontOutlineWidth  = 5,
    fontOutlineWeight = 5,

    iconRelativeX = 1.0, -- [-1, 1] from left
    iconRelativeY = 1.0, -- [-1, 1] from bottom
    iconOffsetX = -6, -- in pixels
    iconOffsetY = -6, -- in pixels
    iconTextAlignment = "rt", -- right top

    iconSizes = {
        small = {
            iconText = "S",
            iconColor = { 1.00, 1.00, 0.00 },
        },
        medium = {
            iconText = "M",
            iconColor = { 1.00, 0.55, 0.00 },
            extraOffsetX = 1,
        },
        large = {
            iconText = "L",
            iconColor = { 1.00, 0.10, 0.35 },
        },
    },
}

local sourceBuildPicsFolder = "unitpics/"
local outputBuildPicsFolder = "output/unitpics/"

local RESET_COLOR_CODE = "\008"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function createFboTexture(sizeX, sizeY)
    return glCreateTexture(sizeX, sizeY, {
		format = GL_RGBA,
		border = false,
		min_filter = GL.LINEAR,
		mag_filter = GL.LINEAR,
		wrap_s = GL.CLAMP_TO_EDGE,
		wrap_t = GL.CLAMP_TO_EDGE,
		fbo = true,
	})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function getFileNameAndExtension (fullFileName)
    local fileName, fileExtension = string_match(fullFileName, "^(.*)(%.[^.]*)$")
    if (fileName ~= nil) then
        return fileName, fileExtension
    else
        return fullFileName, ""
    end
end

local function DrawBuildPicIcon(ud, buildPicTexture, texInfo, iconFont, config)
    local iconConfig = sizeIconsConfig.iconSizes[ config.buildPicConfigKey ]

    local text = iconConfig.iconText
    local xScale = 2.0 / texInfo.xsize
    local yScale = 2.0 / texInfo.ysize
    local offsetX = sizeIconsConfig.iconOffsetX + (iconConfig.extraOffsetX or 0)
    local offsetY = sizeIconsConfig.iconOffsetY + (iconConfig.extraOffsetY or 0)

	glMatrixMode(GL_TEXTURE)

    glRenderToTexture(buildPicTexture, function()
        local textHeight, textDescender = iconFont:GetTextHeight(text)
        local textSizeMult = 0.75 / textHeight -- rescale letters for which textHeight ~= 0.75

        glPushMatrix()
            glTranslate(sizeIconsConfig.iconRelativeX, sizeIconsConfig.iconRelativeY, 0)
            glScale(xScale, yScale, 1)
            glTranslate(offsetX, offsetY, 0)
			glScale(textSizeMult, textSizeMult, 1)

            iconFont:SetTextColor(iconConfig.iconColor)
            iconFont:Print(RESET_COLOR_CODE .. text, 0, 0, sizeIconsConfig.fontSize, sizeIconsConfig.iconTextAlignment .. "o")  -- outlined text needs RESET_COLOR_CODE to not ignore text color (otherwise the text is always white)
        glPopMatrix()
	end)

	glMatrixMode(GL_MODELVIEW)
end

local function GenerateUnitDefBuildPic (ud, iconFont)
    local config = unitSizesConfig[ ud.customParams.unitsize ]

    local sourceBuildPic = ud.customParams.sourcebuildpic
    local sourceBuildPicName, buildPicExtension = getFileNameAndExtension(sourceBuildPic)
    local sourceBuildPicPath = sourceBuildPicsFolder .. sourceBuildPic
    local outputBuildPicPath = outputBuildPicsFolder .. sourceBuildPicName .. config.buildPicPostfix .. buildPicExtension

    local texInfo = glTextureInfo(sourceBuildPicPath)
	local buildPicTexture = createFboTexture(texInfo.xsize, texInfo.ysize)

    glBlending(false)

	glTexture(sourceBuildPicPath)
	glRenderToTexture(buildPicTexture, function()
		glTexRect(-1, -1, 1, 1)
	end)
	glTexture(false)

    DrawBuildPicIcon(ud, buildPicTexture, texInfo, iconFont, config)

	glRenderToTexture(buildPicTexture, glSaveImage, 0, 0, texInfo.xsize, texInfo.ysize, outputBuildPicPath, { alpha = true })
	
	glDeleteTextureFBO(buildPicTexture)
	glDeleteTexture(buildPicTexture)
end

local function GenerateAllRequiredBuildPics()
    Spring.Echo("Generating build pics...")

    local iconFont = gl.LoadFont(sizeIconsConfig.fontPath, sizeIconsConfig.fontSize, sizeIconsConfig.fontOutlineWidth, sizeIconsConfig.fontOutlineWeight)
    local unitCount = 0

    for _, ud in ipairs(UnitDefs) do
        if (ud.customParams.unitsize) then
            GenerateUnitDefBuildPic(ud, iconFont)
            unitCount = unitCount + 1
        end
    end

    gl.DeleteFont(iconFont)

    Spring.Echo("Build pics for " .. unitCount .. " units generated successfully.")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local drawCount = 0

function gadget:DrawGenesis()
    drawCount = drawCount + 1

    if (drawCount >= 2) then  -- skip first Draw because for some reason textures rendered then are bugged
        GenerateAllRequiredBuildPics()

        gadgetHandler:RemoveGadget()
    end
end
