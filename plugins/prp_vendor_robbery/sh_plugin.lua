PLUGIN.name = "Vendor Robbery"
PLUGIN.author = "sil"
PLUGIN.description = "Allows players to rob vendors."

ix.util.Include("hooks/sv_hooks.lua")
ix.util.Include("hooks/cl_hooks.lua")
ix.util.Include("hooks/sh_hooks.lua")

ix.config.Add("NPCRobberyAlarmTime", 30, "How long to disable the vendor after the robbery is complete/failed?", nil, {
    category = "Vendor Robbery",
    data = {min = 5, max = 60, decimals = 0}
})

ix.config.Add("NPCRobberyHoldTime", 30, "How long they have to be looking at the NPC to rob them.", nil, {
    category = "Vendor Robbery",
    data = {min = 5, max = 60, decimals = 0}
})

ix.config.Add("NPCRobberyPoliceChance", 0.2, "Chance of the police being called after a successful robbery.", nil, {
    category = "Vendor Robbery",
    data = {min = 0, max = 1, decimals = 2}
})

ix.config.Add("NPCRobberyScreamChance", 0.3, "Chance of the NPC screaming at the start of a robbery.", nil, {
    category = "Vendor Robbery",
    data = {min = 0, max = 1, decimals = 2}
})