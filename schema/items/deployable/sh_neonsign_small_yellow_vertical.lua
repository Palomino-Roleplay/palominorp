ITEM.name = "Small Vertical Yellow Neon Sign"
ITEM.model = "models/props_combine/combine_light002a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = ""
ITEM.category = "Neon Signs"
ITEM.entClass = "prp_neon_sign"

function ITEM:OnSpawn( eEntity, pPlayer )
    eEntity:SetSignScale( 0.25 )
    eEntity:SetSignVertical( true )
    eEntity:SetSignColor( Vector( 1, 1, 0 ) )
end