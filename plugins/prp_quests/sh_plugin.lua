local PLUGIN = PLUGIN

PLUGIN.name = "Quests"
PLUGIN.author = "sil"
PLUGIN.description = "Skill progression & tutorials"

ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sv_character.lua")

-- @TODO: Consider networking these manually. Right now updating a quest will cause the entire table to be sent to the client.
ix.char.RegisterVar("activeQuests", {
    default = {},
    isLocal = true,
    bNoDisplay = true,
    field = "questsActive",
    fieldType = ix.type.text,
})

ix.char.RegisterVar("completedQuests", {
    default = {},
    isLocal = true,
    bNoDisplay = true,
    field = "questsCompleted",
    fieldType = ix.type.text,
})