local PLUGIN = PLUGIN;

PRP = PRP or {}
PRP.Property = PRP.Property or {}

PRP.Property.PhysgunnedEntity = nil
PRP.Property.PhysgunnedEntityClient = nil

function PLUGIN:PhysgunDrop( pPlayer, eEntity )
    if pPlayer == LocalPlayer() then
        PRP.Prop.PhysgunnedEntity = nil

        SafeRemoveEntity( PRP.Property.PhysgunnedEntityClient )

        PRP.Property.PhysgunnedEntityClient = nil
    end

    return
end

local matGradientUp = Material( "vgui/gradient_up" )
local matGradientDown = Material( "vgui/gradient_down" )
local matWireframe = Material( "editor/wireframe" )
local oGradientColor = Color( 164, 32, 32, 128 )

local function DrawGradientBox(pos1, pos2)
    render.DepthRange(0, 0.01)

    local vPosMin = Vector(
        math.min(pos1.x, pos2.x),
        math.min(pos1.y, pos2.y),
        math.min(pos1.z, pos2.z)
    )

    local vPosMax = Vector(
        math.max(pos1.x, pos2.x),
        math.max(pos1.y, pos2.y),
        math.max(pos1.z, pos2.z)
    )

    render.SetMaterial(matGradientUp)
    local upperZ = vPosMin.z + 32

    -- Front, Back, Right, Left (1st Side)
    render.DrawQuad(Vector(vPosMax.x, vPosMax.y, upperZ), Vector(vPosMin.x, vPosMax.y, upperZ), Vector(vPosMin.x, vPosMax.y, vPosMin.z), Vector(vPosMax.x, vPosMax.y, vPosMin.z), oGradientColor )
    render.DrawQuad(Vector(vPosMin.x, vPosMin.y, upperZ), Vector(vPosMax.x, vPosMin.y, upperZ), Vector(vPosMax.x, vPosMin.y, vPosMin.z), Vector(vPosMin.x, vPosMin.y, vPosMin.z), oGradientColor )
    render.DrawQuad(Vector(vPosMax.x, vPosMax.y, upperZ), Vector(vPosMax.x, vPosMin.y, upperZ), Vector(vPosMax.x, vPosMin.y, vPosMin.z), Vector(vPosMax.x, vPosMax.y, vPosMin.z), oGradientColor )
    render.DrawQuad(Vector(vPosMin.x, vPosMin.y, upperZ), Vector(vPosMin.x, vPosMax.y, upperZ), Vector(vPosMin.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMin.y, vPosMin.z), oGradientColor )

    render.SetMaterial(matGradientDown)

    -- Front, Back, Right, Left (2nd Side)
    render.DrawQuad(Vector(vPosMax.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMax.y, upperZ), Vector(vPosMax.x, vPosMax.y, upperZ), oGradientColor )
    render.DrawQuad(Vector(vPosMin.x, vPosMin.y, vPosMin.z), Vector(vPosMax.x, vPosMin.y, vPosMin.z), Vector(vPosMax.x, vPosMin.y, upperZ), Vector(vPosMin.x, vPosMin.y, upperZ), oGradientColor )
    render.DrawQuad(Vector(vPosMax.x, vPosMax.y, vPosMin.z), Vector(vPosMax.x, vPosMin.y, vPosMin.z), Vector(vPosMax.x, vPosMin.y, upperZ), Vector(vPosMax.x, vPosMax.y, upperZ), oGradientColor )
    render.DrawQuad(Vector(vPosMin.x, vPosMin.y, vPosMin.z), Vector(vPosMin.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMax.y, upperZ), Vector(vPosMin.x, vPosMin.y, upperZ), oGradientColor )

    -- Bottom
    render.SetColorMaterial()
    render.DrawQuad(Vector(vPosMax.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMin.y, vPosMin.z), Vector(vPosMax.x, vPosMin.y, vPosMin.z), oGradientColor )
    render.DrawQuad(Vector(vPosMax.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMax.y, vPosMin.z), Vector(vPosMin.x, vPosMin.y, vPosMin.z), Vector(vPosMax.x, vPosMin.y, vPosMin.z), oGradientColor )

    render.DepthRange(0, 1)
end



function PLUGIN:PostDrawTranslucentRenderables()
    if not IsValid( PRP.Prop.PhysgunnedEntity ) then return end
    if not PRP.Prop.PhysgunnedEntity:GetProperty() then return end
    if not PRP.Prop.PhysgunnedEntity:GetCategory() then return end

    local oProperty = PRP.Prop.PhysgunnedEntity:GetProperty()

    local vHitBoxMin, vHitBoxMax = PRP.Prop.PhysgunnedEntity:OBBMins(), PRP.Prop.PhysgunnedEntity:OBBMaxs()

    local oCategory = PRP.Prop.PhysgunnedEntity:GetCategory()
    local tModelTable = oCategory:GetModel( PRP.Prop.PhysgunnedEntity:GetModel() )
    if tModelTable.cfg.bboxMult then
        vHitBoxMin:Mul( tModelTable.cfg.bboxMult )
        vHitBoxMax:Mul( tModelTable.cfg.bboxMult )
    end

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

        if not vSnappedPos:IsEqualTol( PRP.Property.PhysgunnedEntityClient:GetPos(), 1 ) then
            PRP.Property.PhysgunnedEntityClient:SetPos( vSnappedPos )
            PRP.Property.PhysgunnedEntityClient:SetAngles( aSnappedAng )
            PRP.Property.PhysgunnedEntityClient:SetColor( Color( 50, 200, 150, 32 ) )
        end

        -- Draw intersecting entities
        local tFilter = { [tSnappedPoints.theirs.entity:EntIndex()] = true }
        tIntersectingEntities = PRP.Prop.PhysgunnedEntity:CalcIntersect( vSnappedPos, vTargetAng, tFilter )
        for _, eEntity in pairs( tIntersectingEntities ) do
            -- render.DrawWireframeBox(
            --     eEntity:GetPos(),
            --     eEntity:GetAngles(),
            --     eEntity:OBBMins(),
            --     eEntity:OBBMaxs(),
            --     Color( 255, 0, 0 ),
            --     false
            -- )
        end

        local oColor = #tIntersectingEntities > 0 and Color( 255, 0, 0 ) or Color( 50, 200, 150 )

        -- render.DrawWireframeBox(
        --     vSnappedPos,
        --     aSnappedAng,
        --     vHitBoxMin,
        --     vHitBoxMax,
        --     oColor,
        --     false
        -- )

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
        -- PRP.Property.PhysgunnedEntityClient:SetNoDraw( true )

        PRP.Property.PhysgunnedEntityClient:SetPos( vTargetPos )
        PRP.Property.PhysgunnedEntityClient:SetAngles( vTargetAng )

        local iClientEntityAlpha = 32 * math.ease.InQuad( math.Clamp( PRP.Property.PhysgunnedEntityClient:GetPos():Distance( PRP.Prop.PhysgunnedEntity:GetPos() ) / PRP.Prop.PhysgunnedEntity:BoundingRadius(), 0, 1 ) )
        -- Print( "what in the fuck?" )
        -- Print( PRP.Prop.PhysgunnedEntity:BoundingRadius() )
        -- Print( iClientEntityAlpha )
        PRP.Property.PhysgunnedEntityClient:SetColor4Part( 255, 255, 255, iClientEntityAlpha )

        tIntersectingEntities = PRP.Prop.PhysgunnedEntity:CalcIntersect( vTargetPos, vTargetAng )
        for _, eEntity in pairs( tIntersectingEntities ) do
            -- render.DrawWireframeBox(
            --     eEntity:GetPos(),
            --     eEntity:GetAngles(),
            --     eEntity:OBBMins(),
            --     eEntity:OBBMaxs(),
            --     Color( 255, 0, 0 ),
            --     false
            -- )
        end
    end

    -- Draw property blacklist zones
    local tBlacklistZones = oProperty:GetZonesOfType("prop_blacklist")
    local bInBlacklistZone = PRP.Prop.PhysgunnedEntity:IsInZoneOfType( "prop_blacklist", vTargetPos, vTargetAng )
    for _, tZone in pairs(tBlacklistZones) do
        -- render.DrawWireframeBox(
        --     tZone.pos[1],
        --     Angle(0, 0, 0),
        --     Vector(0, 0, 0),
        --     tZone.pos[2] - tZone.pos[1],
        --     Color(164, 0, 0),
        --     true
        -- )

        DrawGradientBox( tZone.pos[1], tZone.pos[2] )
    end

    local bValidTarget = #tIntersectingEntities == 0 and not bInBlacklistZone

    -- Draw the physgunned entity wireframe box.
    if not tSnappedPoints and not bValidTarget then
        -- render.DrawWireframeBox(
        --     vTargetPos,
        --     vTargetAng,
        --     vHitBoxMin,
        --     vHitBoxMax,
        --     Color( 255, 0, 0 ),
        --     false
        -- )
    end

    local bAllowed = PRP.Prop.PhysgunnedEntity:CalcTarget()
    Print( bAllowed )
end

net.Receive( "PRP.Property.OnPhysgunPickup", function( iLen )
    local eEntity = net.ReadEntity()
    if not IsValid( eEntity ) then return end

    -- @TODO: Call our own hook here

    PRP.Prop.PhysgunnedEntity = eEntity

    PRP.Property.PhysgunnedEntityClient = ClientsideModel( eEntity:GetModel() )
    PRP.Property.PhysgunnedEntityClient:SetBodyGroups( eEntity:GetBodyGroups() )
    PRP.Property.PhysgunnedEntityClient:SetRenderMode( RENDERMODE_TRANSCOLOR )
    PRP.Property.PhysgunnedEntityClient:SetMaterial( "models/wireframe" )
    PRP.Property.PhysgunnedEntityClient:SetColor( Color( 255, 255, 255, 16 ) )
    PRP.Property.PhysgunnedEntityClient:SetPos( eEntity:GetPos() )
    PRP.Property.PhysgunnedEntityClient:SetAngles( eEntity:GetAngles() )
end )