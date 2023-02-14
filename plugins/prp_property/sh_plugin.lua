local PLUGIN = PLUGIN

PLUGIN.name = "Property System"
PLUGIN.author = "sil"
PLUGIN.description = ""

-- @TODO: Do this config better (maybe in the menu)
PLUGIN.config = {
    limits = {
        total = 2,
        category = {
            ["commercial"] = 1,
            ["residential"] = 1,
            ["industrial"] = 1
        }
    }
}

ix.util.Include( "meta/sh_entity.lua" )
ix.util.Include( "meta/sh_property.lua" )
ix.util.Include( "meta/sh_character.lua" )

ix.util.Include( "hooks/sh_property.lua" )
ix.util.Include( "hooks/sv_property.lua" )