local PLUGIN = PLUGIN;

PRP = PRP or {}
PRP.Property = PRP.Property or {}

util.AddNetworkString( "PRP.Property.OnPhysgunPickup" )

function PLUGIN:PhysgunDrop( pPlayer, eEntity )
    if CLIENT then
        if pPlayer == LocalPlayer() then
            PRP.Prop.PhysgunnedEntity = nil
        end

        return
    end
    -- if pPlayer:IsAdmin() then return end
    if not IsValid( eEntity ) then return end

    if not eEntity:GetProperty() then return end
    local oProperty = eEntity:GetProperty()

    if eEntity.PhysgunDrop then
        eEntity:PhysgunDrop( pPlayer )
    end

    if not oProperty:Contains( pPlayer:GetPos() ) or not oProperty:Contains( eEntity:GetPos() ) then
        pPlayer:Notify( "You cannot move your props outside of your property." )
        eEntity:Remove()
        return false
    end

    if oProperty:IsPositionInZoneType( eEntity:GetPos(), "prop_blacklist" ) then
        pPlayer:Notify( "You cannot move your props into this area." )
        eEntity:Remove()
        return false
    end

    eEntity:ResetPhysgunMode()
end