local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: Heist"
PLUGIN.author = "sil"
PLUGIN.description = ""

PRP.Heist = PRP.Heist or {}

ix.util.Include( "meta/sh_heist.lua" )

ix.config.Add( "terminalHackTime", 30, "How long terminals take to hack.", nil, {
    data = { min = 1, max = 120 },
    category = "Palomino: Heist"
} )