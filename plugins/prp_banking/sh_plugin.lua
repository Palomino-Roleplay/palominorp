local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: Banking"
PLUGIN.author = "sil"
PLUGIN.description = "Introduces ATMs & Bank storage."

PRP.Banking = PRP.Banking or {}
PRP.Banking.Config = PRP.Banking.Config or {}

PRP.Banking.Config = {
    w = 5,
    h = 7,
    cost = 10000,
}

ix.util.Include("sv_plugin.lua")



ix.inventory.Register( "banking_character", PRP.Banking.Config.w, PRP.Banking.Config.h, false )

function PRP.Banking.HasAccount( cCharacter )
    return cCharacter:GetData( "banking_inventory_id", false )
end