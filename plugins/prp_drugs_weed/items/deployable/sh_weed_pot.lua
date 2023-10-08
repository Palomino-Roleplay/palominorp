
ITEM.name = "Pot"
ITEM.model = "models/zerochain/props_growop2/zgo2_pot04.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Pot for pot."
ITEM.category = "Weed"
ITEM.entClass = "zgo2_pot"

function ITEM:OnSpawn( eEntity, pPlayer )
    zclib.Player.SetOwner( eEntity, pPlayer )
end