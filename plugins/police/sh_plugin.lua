local PLUGIN = PLUGIN

PLUGIN.name = "Police"
PLUGIN.author = "sil"
PLUGIN.description = "Adds basic police functionality."

ix.util.Include( "sh_arrest.lua" )

ix.util.Include( "meta/sh_character.lua" )
ix.util.Include( "meta/sv_character.lua" )

PLUGIN.PrisonPositions = {
    Vector( 2940, 2203, 144 + 16 ),
}