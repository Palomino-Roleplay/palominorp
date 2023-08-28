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

    local vHitBoxMin, vHitBoxMax = PRP.Prop.PhysgunnedEntity:OBBMins(), PRP.Prop.PhysgunnedEntity:OBBMaxs()
    local vTargetPos, vTargetAng = PRP.Prop.PhysgunnedEntity:CalcFloor()

    render.SetColorMaterial()

    -- Snap Points
    local tSnappedPoints, tUnsnappedPoints = PRP.Prop.PhysgunnedEntity:CalcSnappingPoints( true )

    -- Unsnapped Points
    for _, tUnsnappedPoint in pairs( tUnsnappedPoints or {} ) do
        if tUnsnappedPoint.worldPoint:DistToSqr( LocalPlayer():GetPos() ) > 262144 then continue end

        render.DrawSphere(
            tUnsnappedPoint.worldPoint,
            2,
            8,
            8,
            Color( 255, 255, 255 )
        )
    end

    local tIntersectingEntities

    -- Snapped Points
    if tSnappedPoints then
        local vSnappedPos, aSnappedAng = PRP.Prop.PhysgunnedEntity:CalcSnappingPos( vTargetPos, vTargetAng, tSnappedPoints )

        -- Draw intersecting entities
        local tFilter = { [tSnappedPoints.theirs.entity:EntIndex()] = true }
        tIntersectingEntities = PRP.Prop.PhysgunnedEntity:CalcIntersect( vSnappedPos, vTargetAng, tFilter )
        for _, eEntity in pairs( tIntersectingEntities ) do
            render.DrawWireframeBox(
                eEntity:GetPos(),
                eEntity:GetAngles(),
                eEntity:OBBMins(),
                eEntity:OBBMaxs(),
                Color( 255, 0, 0 ),
                false
            )
        end

        local oColor = #tIntersectingEntities > 0 and Color( 255, 0, 0 ) or Color( 50, 200, 150 )

        render.DrawWireframeBox(
            vSnappedPos,
            aSnappedAng,
            vHitBoxMin,
            vHitBoxMax,
            oColor,
            false
        )

        for _, tSnappedPoint in pairs( tSnappedPoints ) do
            render.DrawSphere(
                tSnappedPoint.worldPoint,
                2,
                8,
                8,
                oColor
            )
        end

        -- Draw line
        render.DrawLine(
            tSnappedPoints.ours.worldPoint,
            tSnappedPoints.theirs.worldPoint,
            oColor,
            false
        )
    else
        tIntersectingEntities = PRP.Prop.PhysgunnedEntity:CalcIntersect( vTargetPos, vTargetAng )
        for _, eEntity in pairs( tIntersectingEntities ) do
            render.DrawWireframeBox(
                eEntity:GetPos(),
                eEntity:GetAngles(),
                eEntity:OBBMins(),
                eEntity:OBBMaxs(),
                Color( 255, 0, 0 ),
                false
            )
        end
    end

    -- Draw property blacklist zones
    local tBlacklistZones = oProperty:GetZonesOfType("prop_blacklist")
    local bInBlacklistZone = PRP.Prop.PhysgunnedEntity:IsInZoneOfType( "prop_blacklist", vTargetPos, vTargetAng )
    for _, tZone in pairs(tBlacklistZones) do
        render.DrawWireframeBox(
            tZone.pos[1],
            Angle(0, 0, 0),
            Vector(0, 0, 0),
            tZone.pos[2] - tZone.pos[1],
            Color(164, 0, 0),
            true
        )
    end

    local bValidTarget = #tIntersectingEntities == 0 and not bInBlacklistZone

    -- Draw the physgunned entity wireframe box.
    if not tSnappedPoints then
        render.DrawWireframeBox(
            vTargetPos,
            vTargetAng,
            vHitBoxMin,
            vHitBoxMax,
            bValidTarget and Color( 255, 255, 255 ) or Color( 255, 0, 0 ),
            false
        )
    end

    local bAllowed = PRP.Prop.PhysgunnedEntity:CalcTarget()
    Print( bAllowed )
end

net.Receive( "PRP.Property.OnPhysgunPickup", function( iLen )
    Print( "hi, are you receiving?" )
    local eEntity = net.ReadEntity()
    if not IsValid( eEntity ) then return end

    -- @TODO: Call our own hook here

    PRP.Prop.PhysgunnedEntity = eEntity
end )