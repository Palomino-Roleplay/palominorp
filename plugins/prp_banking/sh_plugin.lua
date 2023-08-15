local PLUGIN = PLUGIN

PRP.Banking = PRP.Banking or {}

PLUGIN.name = "Banking"
PLUGIN.author = "sil"
PLUGIN.description = "Introduces ATMs & Bank storage."

ix.util.Include("hooks/sv_hooks.lua")

ix.inventory.Register( "banking_character", 5, 7, false )