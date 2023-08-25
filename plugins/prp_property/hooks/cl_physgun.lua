local PLUGIN = PLUGIN;

PRP = PRP or {}
PRP.Property = PRP.Property or {}

PRP.Property.PhysgunnedEntity = nil

function PLUGIN:PhysgunDrop( pPlayer, eEntity )
    if pPlayer == LocalPlayer() then
        PRP.Prop.PhysgunnedEntity = nil
    end

    return
end

function PLUGIN:PostDrawTranslucentRenderables()
    -- Print( "PhysgunnedEntity:", PRP.Prop.PhysgunnedEntity )
    if not IsValid( PRP.Prop.PhysgunnedEntity ) then return end

    if not PRP.Prop.PhysgunnedEntity:GetProperty() then return end

    local oProperty = PRP.Prop.PhysgunnedEntity:GetProperty()
    local bIsDefensiveProp = string.StartsWith( PRP.Prop.PhysgunnedEntity:GetNW2String( "PRP.Prop.Category", "" ), "defensive_props" )
    -- local vPos = PRP.Prop.PhysgunnedEntity:GetPos()
    local vTargetPos = PRP.Prop.PhysgunnedEntity:GetPos()
    local iFloorZ = oProperty:GetFloorZ()

    local vHitBoxMin, vHitBoxMax = PRP.Prop.PhysgunnedEntity:GetCollisionBounds()
    local vHitBoxMinWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMin )
    local vHitBoxMaxWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMax )

    if bIsDefensiveProp then
        vTargetPos.z = iFloorZ
        vHitBoxMinWorld.z = iFloorZ
    end

    local bIntersectingAny = false

    -- prop_blacklist zone
    local tBlacklistZones = oProperty:GetZonesOfType( "prop_blacklist" )
    for _, oZone in pairs( tBlacklistZones ) do
        local vZoneMidpoint = ( oZone.pos[ 1 ] + oZone.pos[ 2 ] ) / 2

        local vZoneSize = Vector(
            math.abs(oZone.pos[1].x - oZone.pos[2].x) / 2,
            math.abs(oZone.pos[1].y - oZone.pos[2].y) / 2,
            math.abs(oZone.pos[1].z - oZone.pos[2].z) / 2
        )

        local flZoneMaxAxis = math.max( vZoneSize.x, vZoneSize.y )
        local flZoneMinAxis = math.min( vZoneSize.x, vZoneSize.y )

        local flDistance = vTargetPos:DistToSqr( vZoneMidpoint )
        local flShapeRatio = flZoneMaxAxis / flZoneMinAxis
        local flDistanceFraction = ( ( flDistance / ( flZoneMaxAxis * flZoneMaxAxis ) ) / flShapeRatio ) / 2

        -- local flFadePercentage = math.Clamp( flDistanceFraction / flShapeRatio, 0, 1 )

        local flDisplayFaction = math.min( 1 - flDistanceFraction, 1 )

        if flDisplayFaction < 0 then continue end

        local bIntersectingZone = util.IsOBBIntersectingOBB(
            vTargetPos,
            PRP.Prop.PhysgunnedEntity:GetAngles(),
            vHitBoxMin,
            vHitBoxMax,
            vZoneMidpoint,
            Angle(0, 0, 0),
            -vZoneSize,
            vZoneSize,
            0
        )
        render.DrawWireframeBox(
            oZone.pos[ 1 ],
            Angle( 0, 0, 0 ),
            Vector( 0, 0, 0 ),
            oZone.pos[ 2 ] - oZone.pos[ 1 ],
            Color( 0, 0, 0, 255 * flDisplayFaction )
        )

        render.SetColorMaterial()

        render.DrawBox(
            oZone.pos[ 1 ],
            Angle( 0, 0, 0 ),
            Vector( 0, 0, 0 ),
            oZone.pos[ 2 ] - oZone.pos[ 1 ],
            Color( 255, 0, 0, 32 * flDisplayFaction ),
            true
        )

        bIntersectingAny = bIntersectingAny or bIntersectingZone
    end

    for _, eEntity in pairs( ents.FindInBox( vHitBoxMinWorld, vHitBoxMaxWorld ) ) do
        if not IsValid( eEntity ) then continue end
        if eEntity:IsWeapon() then continue end
        -- if bIntersectingAny then break end

        if eEntity == PRP.Prop.PhysgunnedEntity then continue end

        render.DrawWireframeBox(
            eEntity:GetPos(),
            eEntity:GetAngles(),
            eEntity:OBBMins(),
            eEntity:OBBMaxs(),
            Color( 255, 0, 0 ),
            false
        )

        bIntersectingAny = true
    end

    if bIsDefensiveProp then
        local oColor = bIntersectingAny and Color( 255, 0, 0 ) or Color( 255, 255, 255 )

        render.DrawWireframeBox(
            vTargetPos,
            PRP.Prop.PhysgunnedEntity:GetAngles(),
            vHitBoxMin,
            vHitBoxMax,
            oColor,
            false
        )

        render.DrawLine(
            PRP.Prop.PhysgunnedEntity:GetPos(),
            vTargetPos,
            oColor,
            false
        )
    end

    -- Property Bounds box
    -- local tBounds = oProperty:GetBounds()
    -- for _, tBound in pairs( tBounds ) do
    --     local vMin = tBound[ 1 ]
    --     local vMax = tBound[ 2 ]

    --     render.DrawWireframeBox(
    --         vMin,
    --         Angle( 0, 0, 0 ),
    --         Vector( 0, 0, 0 ),
    --         vMax - vMin,
    --         Color( 255, 255, 255 ),
    --         true
    --     )
    -- end
end

net.Receive( "PRP.Property.OnPhysgunPickup", function( iLen )
    Print( "hi, are you receiving?" )
    local eEntity = net.ReadEntity()
    if not IsValid( eEntity ) then return end

    -- @TODO: Call our own hook here

    PRP.Prop.PhysgunnedEntity = eEntity
    Print( "PRP.Prop.PhysgunnedEntity: ", PRP.Prop.PhysgunnedEntity )

    local sCategory = eEntity:GetNW2String( "PRP.Prop.Category", nil )
    if not sCategory then return end

    -- eEntity.m_iOriginalCollisionGroup = eEntity.m_iOriginalCollisionGroup or eEntity:GetCollisionGroup()
    -- eEntity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
end )