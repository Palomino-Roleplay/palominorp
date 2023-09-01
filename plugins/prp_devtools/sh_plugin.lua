local PLUGIN = PLUGIN

PLUGIN.name = "Dev Tools"
PLUGIN.author = "sil"
PLUGIN.description = "Tools for debugging and development."

PLUGIN.developers = {
    ["STEAM_0:1:56142649"] = "sil",
    ["STEAM_0:1:18519180"] = "Knight",
    -- @TODO: Remove from production
    ["STEAM_0:0:0"] = "Multirun"
}

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

local PLY = FindMetaTable("Player")

function PLY:IsDeveloper()
    return PLUGIN.developers[self:SteamID()]
end

PLUGIN.Print( "Loaded successfully." )