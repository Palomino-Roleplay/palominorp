
ITEM.name = "Lamp"
ITEM.model = "models/zerochain/props_growop2/zgo2_sodium_lamp01.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.description = "Light that closely matches the sun."
ITEM.category = "Weed"
ITEM.entClass = "zgo2_lamp"

function ITEM:OnSpawn( eEntity, pPlayer )
    zclib.Player.SetOwner( eEntity, pPlayer )
end