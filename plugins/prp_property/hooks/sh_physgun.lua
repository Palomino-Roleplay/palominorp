local PLUGIN = PLUGIN;

PRP = PRP or {}
PRP.Property = PRP.Property or {}

function PLUGIN:OnPhysgunPickup( pPlayer, eEntity )
    -- Print( "OnPhysgunPickup" )
    if CLIENT then return end

    -- @TODO: Make this (& other construction admin checks) permissions based
    -- if pPlayer:IsSuperAdmin() then return end
    if not IsValid( eEntity ) then return end

    if not eEntity:GetProperty() then return end
    local oProperty = eEntity:GetProperty()

    -- When we force drop the entity to the floor, we might go a little bit out of bounds.
    -- This is to prevent deletion of the entity after the last movement was a force drop.
    if ( not eEntity._bWasDropped ) and ( not oProperty:Contains( pPlayer:GetPos() ) or not oProperty:Contains( eEntity:GetPos() ) ) then
        pPlayer:Notify( "You cannot move your props outside of your property." )
        eEntity:Remove()

        return false
    end
    eEntity._bWasDropped = false

    -- if eEntity.OnPhysgunPickup then
    --     eEntity:OnPhysgunPickup( pPlayer )
    -- end

    eEntity:SetPhysgunMode( PRP.PHYSGUN_MODE_SAFE )

    if SERVER then
        net.Start( "PRP.Property.OnPhysgunPickup" )
            Print( "hello? why arent u sending" )
            net.WriteEntity( eEntity )
        net.Send( pPlayer )
    end
end

function PLUGIN:OnPhysgunFreeze( eWeapon, oPhysics, eEntity, pPlayer )
    -- if pPlayer:IsAdmin() then return end
    if not IsValid( eEntity ) then return end

    return false
end