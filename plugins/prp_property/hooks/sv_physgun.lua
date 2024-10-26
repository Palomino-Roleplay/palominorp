local PLUGIN = PLUGIN;

PRP = PRP or {}
PRP.Property = PRP.Property or {}

util.AddNetworkString( "PRP.Property.OnPhysgunPickup" )

function PLUGIN:OnPhysgunFreeze( eWeapon, oPhysics, eTarget, pPlayer )
    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassPhysgunLimits" ) then return end

    -- @TODO: Let them freeze *some* props like decor props or w/e (maybe make it part of prop config?)
    return false
end

function PLUGIN:OnPhysgunPickup( pPlayer, eEntity )
    -- @TODO: Make this (& other construction admin checks) permissions based
    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassPhysgunLimits" ) then return end
    if not IsValid( eEntity ) then return end

    if not eEntity:GetRealty() then return end
    local oProperty = eEntity:GetRealty()

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

    net.Start( "PRP.Property.OnPhysgunPickup" )
        net.WriteEntity( eEntity )
    net.Send( pPlayer )
end

function PLUGIN:OnPhysgunReload( eWeapon, pPlayer )
    -- @TODO: Allow for staff
    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassPhysgunLimits" ) then return true end

    return false
end

function PLUGIN:PhysgunDrop( pPlayer, eEntity )
    -- if pPlayer:IsAdmin() then return end
    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassPhysgunLimits" ) then return end
    if not IsValid( eEntity ) then return end

    if not eEntity:GetRealty() then return end
    local oProperty = eEntity:GetRealty()

    -- Prop-snapping, floor-snapping, zone-blocking, collision blocking, and whatever else.
    local bValid, vTargetPos, aTargetAng = eEntity:CalcTarget()
    if not bValid then
        pPlayer:Notify( "Invalid Position." )
        eEntity:Remove()
        return false
    end
    eEntity:SetPos( vTargetPos )
    eEntity:SetAngles( aTargetAng )

    if eEntity.PhysgunDrop then
        eEntity:PhysgunDrop( pPlayer )
    end

    eEntity:ResetPhysgunMode()

    local bHasAccess = CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassPhysgunLimits" )
    if bHasAccess then return end

    if not oProperty:Contains( pPlayer:GetPos() ) or not oProperty:Contains( eEntity:GetPos() ) then
        pPlayer:Notify( "You cannot move your props outside of your property." )
        eEntity:Remove()
        return false
    end

    -- @TODO: Maybe this sort of stuff is better configured in the zone config, not here.
    if oProperty:IsPositionInZoneType( eEntity:GetPos(), "prop_blacklist" ) then
        pPlayer:Notify( "You cannot move your props into this area." )
        eEntity:Remove()
        return false
    end

    -- @TODO: Check for collisions w/ world
end