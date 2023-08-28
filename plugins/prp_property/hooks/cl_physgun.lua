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

    local vHitBoxMin, vHitBoxMax = PRP.Prop.PhysgunnedEntity:OBBMins(), PRP.Prop.PhysgunnedEntity:OBBMaxs()
    local vHitBoxMinWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMin )
    local vHitBoxMaxWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMax )

    -- @TODO: I'm sure we can do this better than hardcoding it.
    if string.StartsWith( oCategory:GetID(), "defensive_props" ) then
        vTargetPos.z = iFloorZ
        vHitBoxMinWorld.z = iFloorZ
    end

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

        local vSnappedPos, aSnappedAng = PRP.Prop.PhysgunnedEntity:CalcSnappingPos( vTargetPos, vTargetAng, tSnappedPoints )

        Print( "Pos/Ang:" )
        Print( vSnappedPos )
        -- Print( "Ang:" )
        Print( aSnappedAng )

        render.DrawWireframeBox(
            vSnappedPos,
            aSnappedAng,
            vHitBoxMin,
            vHitBoxMax,
            Color( 50, 200, 150 ),
            false
        )
    end

    -- Draw property blacklist zones
    local tBlacklistZones = oProperty:GetZonesOfType("prop_blacklist")
    for _, tZone in pairs(tBlacklistZones) do
        render.DrawWireframeBox(
            tZone.pos[1],
            Angle(0, 0, 0),
            Vector(0, 0, 0),
            tZone.pos[2] - tZone.pos[1],
            Color(255, 0, 0),
            true
        )
    end

    local tIntersectingEntities = PRP.Prop.PhysgunnedEntity:CalcIntersect( vTargetPos, vTargetAng )

    -- Draw intersecting entities
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

    -- Draw the physgunned entity wireframe box.
    render.DrawWireframeBox(
        vTargetPos,
        vTargetAng,
        vHitBoxMin,
        vHitBoxMax,
        Color( 255, 255, 255 ),
        false
    )
end

net.Receive( "PRP.Property.OnPhysgunPickup", function( iLen )
    Print( "hi, are you receiving?" )
    local eEntity = net.ReadEntity()
    if not IsValid( eEntity ) then return end

    -- @TODO: Call our own hook here

    PRP.Prop.PhysgunnedEntity = eEntity
end )