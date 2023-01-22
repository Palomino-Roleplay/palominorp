local PLUGIN = PLUGIN

PLUGIN.name = "Radio"
PLUGIN.author = "sil"
PLUGIN.description = "Adds a 2-way radio"

ix.util.Include( "meta/sv_character.lua" )
ix.util.Include( "meta/sh_character.lua" )
ix.util.Include( "meta/cl_character.lua" )

ix.util.Include( "meta/sh_player.lua" )


ix.util.Include( "hooks/sv_radio.lua" )
ix.util.Include( "hooks/sh_radio.lua" )
ix.util.Include( "hooks/cl_radio.lua" )

-- @TODO: Move to binds plugin thingy
ix.option.Add( "speakInRadio", ix.type.number, KEY_B, {
    category = "binds",
    bNetworked = true,
    min = KEY_NONE,
    max = KEY_LAST,
    decimals = 0
} )