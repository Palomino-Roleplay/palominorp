local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: Heist"
PLUGIN.author = "sil"
PLUGIN.description = ""

PRP.Heist = PRP.Heist or {}

ix.util.Include( "meta/sh_heist.lua" )
ix.util.Include( "meta/sv_player.lua" )

ix.config.Add( "heistLootTime", 10, "Number of seconds it takes to grab money.", nil, {
    data = { min = 1, max = 30 },
    category = "Palomino: Heists"
} )

ix.config.Add( "terminalHackTime", 30, "How long terminals take to hack.", nil, {
    data = { min = 1, max = 120 },
    category = "Palomino: Heists"
} )

ix.config.Add( "gasPropagateTime", 30, "How long it takes for the gas canister to propagate across the entire laser hallway.", nil, {
    data = { min = 1, max = 120 },
    category = "Palomino: Heists"
} )

ix.config.Add( "heistLootDistance", 15000000, "Square of the distance required for them to be considered safe.", nil, {
    data = { min = 100000, max = 1000000000 },
    category = "Palomino: Heists"
} )

ix.config.Add( "heistLootTimer", 15, "Number of minutes a player has to stay away from the bank to be get the loot.", nil, {
    data = { min = 1, max = 30 },
    category = "Palomino: Heists"
} )