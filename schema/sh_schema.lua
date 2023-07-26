Schema.name = "PRP"
Schema.author = "sil"
Schema.description = ""
Schema.version = "Closed Pre-Alpha"

ix.util.Include("cl_schema.lua")

ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")

-- Hooks
ix.util.Include("hooks/sv_hooks.lua")
ix.util.Include("hooks/sh_hooks.lua")
ix.util.Include("hooks/cl_hooks.lua")

-- Default config values
ix.config.SetDefault( "intro", false )

-- Config values
ix.config.Add("DeveloperMode", false, "Enables some things and makes the server slower.", nil, {
    category = "Palomino"
})

ix.config.Add("EquipTime", 3, "How long does it take for a weapon to be equipped from the inventory.", nil, {
    data = {min = 0, max = 10},
    category = "Palomino"
})

-- CustomizableWeaponry 2 Configs
CustomizableWeaponry.canOpenInteractionMenu = true
CustomizableWeaponry.customizationEnabled = true
CustomizableWeaponry.giveAllAttachmentsOnSpawn = 0