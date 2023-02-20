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

ix.util.Include( "meta/cl_spawnmenu.lua" )
ix.util.Include( "meta/sh_entity.lua" )
ix.util.Include( "meta/sh_character.lua" )
ix.util.Include( "meta/sv_property.lua" )
ix.util.Include( "meta/sh_property.lua" )
ix.util.Include( "meta/cl_property.lua" )

ix.util.Include( "hooks/sh_property.lua" )
ix.util.Include( "hooks/sv_property.lua" )
ix.util.Include( "hooks/cl_property.lua" )
ix.util.Include( "hooks/sv_props.lua" )
ix.util.Include( "hooks/sh_props.lua" )

ix.config.Add("propertyRentPaymentInterval", 15, "How many minutes are there between the rent payments? (Needs map change to update)", nil, {
    data = {min = 1, max = 60, decimals = 0},
    category = "Palomino: Property"
})

ix.config.Add("propertySpawnmenuCooldown", 3, "How many seconds before players can attempt to spawn a prop via the spawnmenu again?", nil, {
    data = {min = 1, max = 10, decimals = 0},
    category = "Palomino: Property"
})