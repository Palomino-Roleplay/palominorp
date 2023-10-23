Schema.name = "PRP"
Schema.author = "sil"
Schema.description = ""
Schema.version = "PRE-ALPHA"

PRP = PRP or {}

-- @TODO: Change after playtest
PRP.API_URL = "https://papi-staging.palomino.life"
PRP.API_KEY = "aFp2bC5P3bhVHWqNTdI7SXljJOtIu2gb"

ix.util.Include("cl_schema.lua")

ix.util.IncludeDir("meta")
ix.util.IncludeDir("hooks")

-- Default config values
ix.config.SetDefault( "intro", false )
ix.config.SetDefault( "music", "" )
ix.config.SetDefault( "font", "Inter Black" )
ix.config.SetDefault( "genericFont", "Inter Medium" )
ix.config.SetDefault( "inventoryHeight", 7 )
ix.config.SetDefault( "inventoryWidth", 5 )
-- ix.config.SetDefault( "doorLockTime", 0 )
ix.config.SetDefault( "allowVoice", true )

-- Config values
ix.config.Add("DeveloperMode", false, "Enables some things and makes the server slower.", nil, {
    category = "Palomino"
})

ix.config.Add("EquipTime", 3, "How long does it take for a weapon to be equipped from the inventory.", nil, {
    data = {min = 0, max = 10},
    category = "Palomino"
})

ix.config.Add("mediaPlayerDistance", 1000000, "Square of the distance to have a nearby media player play", nil, {
    data = {min = 1000, max = 100000000, decimals = 0},
    category = "Palomino"
})

-- CustomizableWeaponry 2 Configs
CustomizableWeaponry.canOpenInteractionMenu = true
CustomizableWeaponry.customizationEnabled = true
CustomizableWeaponry.giveAllAttachmentsOnSpawn = 0