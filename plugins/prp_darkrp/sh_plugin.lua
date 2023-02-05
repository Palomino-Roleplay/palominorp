local PLUGIN = PLUGIN

PLUGIN.name = "DarkRP Functions"
PLUGIN.author = "sil"
PLUGIN.description = "Wrapper for DarkRP addons."

local PLY = FindMetaTable("Player")
DarkRP = DarkRP or {}

ix.util.Include("meta/sh_character.lua")

ix.util.Include("modules/sh_entityvars.lua")

ix.util.Include("addons/advanced_police_mod/sv_apm.lua")
ix.util.Include("addons/advanced_police_mod/cl_apm.lua")
ix.util.Include("addons/advanced_police_mod/sh_apm.lua")

local tDarkRPVars = {}
function PLY:getDarkRPVar( sVar )
    local xVar = tDarkRPVars[sVar]

    if isfunction( xVar ) then
        return xVar( self )
    elseif isbool( xVar ) then
        return xVar
    end
end

function PLY:addDarkRPVar( sVar, xValue )
    tDarkRPVars[sVar] = xValue
end

function DarkRP.formatMoney( iAmount )
    return ix.currency.Get( iAmount )
end

function DarkRP.textWrap( sText, sFont, iWidth )
    return table.concat( ix.util.WrapText( sText, iWidth, sFont ), "\n" )
end