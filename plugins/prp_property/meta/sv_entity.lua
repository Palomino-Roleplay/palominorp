local ENTITY = FindMetaTable( "Entity" )

-- Allow all collisions
PRP.PHYSGUN_MODE_NONE = 0

-- Doesn't collide with players and vehicles
PRP.PHYSGUN_MODE_SAFE = 1

function ENTITY:GetPhysgunMode()
    return self.m_iPhysgunMode or PRP.PHYSGUN_MODE_NONE
end

function ENTITY:SetPhysgunMode( iPhysgunMode )
    if iPhysgunMode == PRP.PHYSGUN_MODE_NONE then

        self:ResetPhysgunMode()

    elseif iPhysgunMode == PRP.PHYSGUN_MODE_SAFE then

        self.m_iOriginalCollisionGroup = self.m_iOriginalCollisionGroup or self:GetCollisionGroup()
        self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
        self:SetRenderMode( RENDERMODE_TRANSTEXTURE )
        self:SetColor4Part( 255, 255, 255, 200 )
        self:SetRenderFX( 2 )

    end

    self.m_iPhysgunMode = iPhysgunMode
end

function ENTITY:ResetPhysgunMode()
    self.m_iOriginalCollisionGroup = self.m_iOriginalCollisionGroup or COLLISION_GROUP_NONE

    self:SetCollisionGroup( self.m_iOriginalCollisionGroup or COLLISION_GROUP_NONE )
    self:SetRenderMode( RENDERMODE_NORMAL )
    self:SetColor4Part( 255, 255, 255, 255 )
    self:SetRenderFX( 0 )

    if self:GetPhysicsObject() then
        self:GetPhysicsObject():SetVelocityInstantaneous( Vector( 0, 0, 0 ) )
        self:GetPhysicsObject():SetAngleVelocityInstantaneous( Vector( 0, 0, 0 ) )
    end

    self.m_iPhysgunMode = PRP.PHYSGUN_MODE_NONE
end