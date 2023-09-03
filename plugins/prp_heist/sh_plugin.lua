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

ix.config.Add( "gasPropagateTime", 30, "How long it takes for the gas canister to propagate across the entire laser hallway.", nil, {
    data = { min = 1, max = 120 },
    category = "Palomino: Heist"
} )