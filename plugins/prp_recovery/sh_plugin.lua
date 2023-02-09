PLUGIN.name = "Recovery"
PLUGIN.author = "sil"
PLUGIN.description = "Recovery in hospital after death"

PLUGIN.spawns = {
    Vector( 8046, 5155, 224 ),
    Vector( 7844, 5148, 224 ),
    Vector( 7836, 5291, 224 ),
    Vector( 8057, 5292, 224 ),
    Vector( 8049, 5578, 224 ),
    Vector( 8052, 5465, 224 ),
}

-- @TODO: Use property system.
PLUGIN.hospital = {
    Vector(6400.03125,4862.9575195313,-63.018222808838),
    Vector(8127.9467773438,5760.03125,735.89385986328)
}

ix.util.Include( "hooks/sv_hooks.lua" )
ix.util.Include( "hooks/sh_hooks.lua" )
ix.util.Include( "hooks/cl_hooks.lua" )

ix.util.Include( "meta/sv_player.lua" )
ix.util.Include( "meta/sh_player.lua" )
ix.util.Include( "meta/cl_player.lua" )