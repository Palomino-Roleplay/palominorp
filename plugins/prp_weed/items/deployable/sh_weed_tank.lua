
ITEM.name = "Water Tank"
ITEM.model = "models/zerochain/props_growop2/zgo2_watertank_small.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.description = "Water tank for growing plants."
ITEM.category = "Weed"
ITEM.entClass = "zgo2_watertank"

function ITEM:OnSpawn( eEntity, pPlayer )
    zclib.Player.SetOwner( eEntity, pPlayer )
end