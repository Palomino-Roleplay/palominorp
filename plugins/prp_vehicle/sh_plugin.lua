local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: Vehicle Utilities"
PLUGIN.author = "sil"
PLUGIN.description = ""

ix.util.Include( "hooks/sv_hooks.lua" )

ix.util.Include( "meta/sv_character.lua" )
ix.util.Include( "meta/sh_character.lua" )
ix.util.Include( "meta/sh_vehicle.lua" )