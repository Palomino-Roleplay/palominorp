local PLUGIN = PLUGIN

PRP.Banking = PRP.Banking or {}
PRP.Banking.Config = PRP.Banking.Config or {}

PRP.Banking.Config = {
    w = 5,
    h = 7,
    cost = 10000,
}

PLUGIN.name = "Banking"
PLUGIN.author = "sil"
PLUGIN.description = "Introduces ATMs & Bank storage."

ix.util.Include("hooks/sv_hooks.lua")

ix.inventory.Register( "banking_character", PRP.Banking.Config.w, PRP.Banking.Config.h, false )