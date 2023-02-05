PLUGIN.name = "Recovery"
PLUGIN.author = "sil"
PLUGIN.description = "Recovery in hospital after death"

PLUGIN.spawns = {
    Vector( -6562, 1229, -256 )
}

-- @TODO: Use property system.
PLUGIN.hospital = {
    Vector( -5696, 2880, -256 ),
    Vector( -7146, 1023, 259 )
}

ix.util.Include( "hooks/sv_hooks.lua" )
ix.util.Include( "hooks/sh_hooks.lua" )
ix.util.Include( "hooks/cl_hooks.lua" )

ix.util.Include( "meta/sv_player.lua" )
ix.util.Include( "meta/sh_player.lua" )
ix.util.Include( "meta/cl_player.lua" )