
ITEM.name = "Jar"
ITEM.model = "models/zerochain/props_growop2/zgo2_jar.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A jar to store totally legal stuff in."
ITEM.category = "Weed"
ITEM.entClass = "zgo2_jar"

function ITEM:OnSpawn( eEntity, pPlayer )
    zclib.Player.SetOwner( eEntity, pPlayer )

    eEntity:SetWeedID( self:GetData( "WeedID", 1 ) )
    eEntity:SetWeedAmount( self:GetData( "WeedAmount", 0 ) )
    eEntity:SetWeedTHC( self:GetData( "WeedTHC", 0 ) )
end

function ITEM:OnPickup( eEntity, pPlayer )
    self:SetData( "WeedID", eEntity:GetWeedID() )
    self:SetData( "WeedAmount", eEntity:GetWeedAmount() )
    self:SetData( "WeedTHC", eEntity:GetWeedTHC() )
end