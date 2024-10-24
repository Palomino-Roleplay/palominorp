PLUGIN.name = "Palomino: Recovery"
PLUGIN.author = "sil"
PLUGIN.description = "Recovery in hospital after death"

-- Some backup spawns
-- @TODO: Gross.
PLUGIN.spawns = {
    Vector( 7073, 5300, 224 ),
    Vector( 7147, 5298, 224 ),
}

PLUGIN.normalSpawns = {
    Vector( 7596, 5075, -56 ),
    Vector( 7471, 5074, -56 ),
    Vector( 7308, 5072, -56 ),
    Vector( 7306, 5214, -56 ),
    Vector( 7451, 5216, -56 ),
    Vector( 7589, 5217, -56 )
}

ix.util.Include( "hooks/cl_hooks.lua" )
ix.util.Include( "hooks/sh_hooks.lua" )
ix.util.Include( "hooks/sv_hooks.lua" )

ix.util.Include( "meta/cl_player.lua" )
ix.util.Include( "meta/sh_player.lua" )
ix.util.Include( "meta/sv_player.lua" )

ix.config.Add( "wheelchairSpawn", false, "Enable spawning in wheelchair mode.", nil, {
    category = "Palomino: Recovery"
} )

ix.config.Add( "recoveryTime", 30, "Seconds after spawn to spend in recovery.", nil, {
    data = { min = 0, max = 600 },
    category = "Palomino: Recovery"
} )