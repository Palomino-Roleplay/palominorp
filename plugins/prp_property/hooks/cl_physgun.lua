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
    if not IsValid( PRP.Prop.PhysgunnedEntity ) then return end
    if not PRP.Prop.PhysgunnedEntity:GetProperty() then return end

    local oProperty = PRP.Prop.PhysgunnedEntity:GetProperty()
    local oCategory = PRP.Prop.PhysgunnedEntity:GetCategory()
    -- local bIsDefensiveProp = string.StartsWith( sCategory, "defensive_props" )

    local vTargetPos = PRP.Prop.PhysgunnedEntity:GetPos()
    local vTargetAng = PRP.Prop.PhysgunnedEntity:GetAngles()

    local iFloorZ = oProperty:GetFloorZ()

    local vHitBoxMin, vHitBoxMax = PRP.Prop.PhysgunnedEntity:GetCollisionBounds()
    local vHitBoxMinWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMin )
    local vHitBoxMaxWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMax )

    if bIsDefensiveProp then
        vTargetPos.z = iFloorZ
        vHitBoxMinWorld.z = iFloorZ
    end

    local bIntersectingAny = false

    local tSnappedPoints, tUnsnappedPoints = PRP.Prop.PhysgunnedEntity:CalcSnapping( true )

    render.SetColorMaterial()

    -- Unsnapped Points
    for _, tUnsnappedPoint in pairs( tUnsnappedPoints ) do
        if tUnsnappedPoint.worldPoint:DistToSqr( LocalPlayer():GetPos() ) > 262144 then continue end

        render.DrawSphere(
            tUnsnappedPoint.worldPoint,
            2,
            8,
            8,
            Color( 255, 255, 255 )
        )
    end

    -- Snapped Points
    if tSnappedPoints then
        for _, tSnappedPoint in pairs( tSnappedPoints ) do
            render.DrawSphere(
                tSnappedPoint.worldPoint,
                2,
                8,
                8,
                Color( 50, 200, 150 )
            )
        end

        -- Draw line
        render.DrawLine(
            tSnappedPoints.ours.worldPoint,
            tSnappedPoints.theirs.worldPoint,
            Color( 50, 200, 150 ),
            false
        )
    end

    if true then return end

    --------------------
    -- SNAP POINTS :) --
    --------------------
    local tAllSnapPoints = {}
    local tHeldSnapPoints = {}
    for _, eEntity in pairs( oProperty:GetProps() or {} ) do
        if not IsValid( eEntity ) then continue end

        -- if v == PRP.Prop.PhysgunnedEntity then continue end

        local tCategoryExploded = string.Explode( "/", sCategory )

        -- @TODO: Fuck this. Hell no.
        local tPropCategoryData = PLUGIN.config.props[tCategoryExploded[1]].subcategories[tCategoryExploded[2]].models[v:GetModel()]
        if not tPropCategoryData.snapPoints then continue end

        for _, tSnapPointData in pairs( tPropCategoryData.snapPoints ) do
            -- Draw snap points
            table.insert( v == PRP.Prop.PhysgunnedEntity and tHeldSnapPoints or tAllSnapPoints, {
                ent = v,
                snap = tSnapPointData
            } )
        end
    end

    local oSnapPointNormalColor = Color( 255, 255, 255 )
    local oSnapPointDisplayColor = Color( 50, 200, 150 )

    -- @TODO: Study leetcode so we're not doing O(n^2) in a render hook...
    local tDisplayedSnapPoints = {}
    for _, tSnapPoint1 in pairs( tAllSnapPoints ) do
        for _, tSnapPoint2 in pairs( tHeldSnapPoints ) do
            if #tDisplayedSnapPoints > 0 then break end
            -- @TODO: Perhaps we should be indexing based on entity and not all snap points...
            if tSnapPoint1.ent == tSnapPoint2.ent then continue end

            if tSnapPoint1.ent:LocalToWorld( tSnapPoint1.snap.point ):DistToSqr( tSnapPoint2.ent:LocalToWorld( tSnapPoint2.snap.point ) ) < 4096 then
                tDisplayedSnapPoints = {
                    tSnapPoint1,
                    tSnapPoint2
                }

                tSnapPoint1.displayed = true
                tSnapPoint2.displayed = true
            end
        end

        render.DrawSphere(
            tSnapPoint1.ent:LocalToWorld( tSnapPoint1.snap.point ),
            2,
            8,
            8,
            tSnapPoint1.displayed and oSnapPointDisplayColor or oSnapPointNormalColor
        )
    end

    for _, tSnapPoint in pairs( tHeldSnapPoints ) do
        -- if tSnapPoint.displayed then continue end

        render.DrawSphere(
            tSnapPoint.ent:LocalToWorld( tSnapPoint.snap.point ),
            2,
            8,
            8,
            tSnapPoint.displayed and oSnapPointDisplayColor or oSnapPointNormalColor
        )
    end
    -- We have a pair of eligible snap points!
    if #tDisplayedSnapPoints > 0 then
        local tSnapPoint1 = tDisplayedSnapPoints[ 1 ]
        local tSnapPoint2 = tDisplayedSnapPoints[ 2 ]

        -- Initial angles and grid
        local targetAng = tSnapPoint1.ent:GetAngles()
        local angleGrid = tSnapPoint1.snap.angleGrid

        Print( angleGrid )

        -- Local angle difference
        local angleDiff = vTargetAng - targetAng
        angleDiff:Normalize()

        -- @TODO: This doesn't actually work for rotation in more than one axis
        local function SnapToGrid(angle, grid)
            return (grid == 360) and 0 or math.Round(angle / grid) * grid
        end

        -- Snap angles
        angleDiff:SetUnpacked(SnapToGrid(angleDiff.p, angleGrid.p), SnapToGrid(angleDiff.y, angleGrid.y), SnapToGrid(angleDiff.r, angleGrid.r))

        -- Calculate final snapped angles without altering the PhysgunnedEntity
        local finalAng = targetAng + angleDiff
        finalAng:Normalize()

        -- Manually calculate world point for the snapped angle
        local mat = Matrix()
        mat:SetAngles(finalAng)
        local vSnapPoint2Local = tSnapPoint2.snap.point
        local vSnapPoint2WorldAdjusted = mat * vSnapPoint2Local + PRP.Prop.PhysgunnedEntity:GetPos()

        -- Draw connecting line
        local vSnapPoint1World = tSnapPoint1.ent:LocalToWorld(tSnapPoint1.snap.point)
        render.DrawLine(vSnapPoint1World, tSnapPoint2.ent:LocalToWorld( tSnapPoint2.snap.point ), oSnapPointDisplayColor, false)

        -- Calculate position offset
        local vAlignVector = vSnapPoint1World - vSnapPoint2WorldAdjusted
        vTargetPos = PRP.Prop.PhysgunnedEntity:GetPos() + vAlignVector

        vTargetAng = finalAng
    end

    ---------------------
    -- /SNAP POINTS :) --
    ---------------------

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
            vTargetAng,
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

    -- Collision w/ other entities
    for _, eEntity in pairs( ents.FindInBox( vHitBoxMinWorld, vHitBoxMaxWorld ) ) do
        if not IsValid( eEntity ) then continue end
        if eEntity:IsWeapon() then continue end
        -- if bIntersectingAny then break end
        if eEntity == PRP.Prop.PhysgunnedEntity then continue end

        if #tDisplayedSnapPoints > 0 and ( ( tDisplayedSnapPoints[ 1 ].ent == eEntity ) or ( tDisplayedSnapPoints[ 2 ].ent == eEntity ) ) then continue end

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

    -- Box of the prop
    if bIsDefensiveProp then
        local oColor = bIntersectingAny and Color( 255, 0, 0 ) or ( #tDisplayedSnapPoints > 0 and oSnapPointDisplayColor or Color( 255, 255, 255 ) )

        render.DrawWireframeBox(
            vTargetPos,
            vTargetAng,
            vHitBoxMin,
            vHitBoxMax,
            oColor,
            false
        )

        if #tDisplayedSnapPoints == 0 then
            render.DrawLine(
                PRP.Prop.PhysgunnedEntity:GetPos(),
                vTargetPos,
                oColor,
                false
            )
        end
    end
end

net.Receive( "PRP.Property.OnPhysgunPickup", function( iLen )
    Print( "hi, are you receiving?" )
    local eEntity = net.ReadEntity()
    if not IsValid( eEntity ) then return end

    -- @TODO: Call our own hook here

    PRP.Prop.PhysgunnedEntity = eEntity
end )