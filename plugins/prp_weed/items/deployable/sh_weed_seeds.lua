
ITEM.name = "Weed Seeds"
ITEM.model = "models/zerochain/props_growop2/zgo2_weedseeds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "So much potential..."
ITEM.category = "Weed"
ITEM.entClass = "zgo2_seed"

function ITEM:OnSpawn( eEntity, pPlayer )
    -- self:SetData("SetPlantID", 1)

    eEntity:SetPlantID( self:GetData( "PlantID", 1 ) )
    eEntity:SetCount( self:GetData( "Count", 1 ) )

    zclib.Player.SetOwner( eEntity, pPlayer )
end