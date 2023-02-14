local PLUGIN = PLUGIN

-- Also see: OnPlayerPhysicsPickup

function PLUGIN:OnPhysgunPickup( pPlayer, eEntity )
    -- if pPlayer:IsAdmin() then return end
    if not IsValid( eEntity ) then return end

    if not eEntity:GetProperty() then return end
    local oProperty = eEntity:GetProperty()

    if not oProperty:Contains( pPlayer:GetPos() ) or not oProperty:Contains( eEntity:GetPos() ) then
        pPlayer:Notify( "You cannot move your props outside of your property." )
        eEntity:Remove()
    end

    eEntity.m_iOriginalCollisionGroup = eEntity.m_iOriginalCollisionGroup or eEntity:GetCollisionGroup()
    eEntity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
end

function PLUGIN:PhysgunDrop( pPlayer, eEntity )
    -- if pPlayer:IsAdmin() then return end
    if not IsValid( eEntity ) then return end

    if not eEntity:GetProperty() then return end
    local oProperty = eEntity:GetProperty()

    if not oProperty:Contains( pPlayer:GetPos() ) or not oProperty:Contains( eEntity:GetPos() ) then
        pPlayer:Notify( "You cannot move your props outside of your property." )
        eEntity:Remove()
        return false
    end

    if not eEntity:GetPhysicsObject() then return end

    eEntity:GetPhysicsObject():SetVelocityInstantaneous( Vector( 0, 0, 0 ) )
    eEntity:GetPhysicsObject():SetAngleVelocityInstantaneous( Vector( 0, 0, 0 ) )

    eEntity:SetCollisionGroup( eEntity.m_iOriginalCollisionGroup or COLLISION_GROUP_NONE )
end