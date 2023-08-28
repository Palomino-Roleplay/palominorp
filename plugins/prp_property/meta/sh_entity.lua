local PLUGIN = PLUGIN

local ENTITY = FindMetaTable( "Entity" )

AccessorFunc( ENTITY, "m_pSpawner", "Spawner" )

function ENTITY:GetProperty()
    if self.m_sPropertyID then return PRP.Property.Get( self.m_sPropertyID ) end

    local sPropertyID = self:GetNWString( "PRP.Property", nil )
    if sPropertyID then
        self.m_sPropertyID = sPropertyID
        return PRP.Property.Get( self.m_sPropertyID )
    end

    return
end

function ENTITY:SetProperty( oProperty )
    if not oProperty then return end

    if CLIENT then return end

    -- @TODO I'm sure we can do this better with our own networking
    self:SetNWString( "PRP.Property", oProperty:GetID() )
end

function ENTITY:HasAccess( cCharacter )
    if not cCharacter then return false end
    if not self:GetProperty() then return false end

    return self:GetProperty():HasAccess( cCharacter )
end

-- @TODO: Perhaps this should only exist for prop_physics?
AccessorFunc( ENTITY, "m_oCategory", "Category" )

function ENTITY:GetCategoryID()
    if self.m_sCategoryID then return self.m_sCategoryID end
    if not self.m_oCategory then return end

    self.m_sCategoryID = self.m_oCategory:GetID()
    return self.m_sCategoryID
end

function ENTITY:SetCategory( oCategory )
    self.m_oCategory = oCategory
    self.m_sCategoryID = oCategory:GetID()

    if CLIENT then return end

    -- @TODO: Do our own networking (NWString has a limit)
    self:SetNWString( "PRP.Category", self.m_sCategoryID )
end

function ENTITY:GetCategory()
    if self.m_oCategory then return self.m_oCategory end

    local sCategoryID = self:GetNWString( "PRP.Category", nil )
    if sCategoryID then
        self.m_oCategory = PRP.Prop.Category.Get( sCategoryID )
        return self.m_oCategory
    end

    return nil
end

function ENTITY:GetSnapPoints()
    if not self:GetCategory() then return end

    local tConfig = self:GetCategory():GetModel( self:GetModel() ).cfg
    if not tConfig then return end

    return tConfig.snapPoints or false
end

-- This looks worse than it is, I promise
-- On client, it's only run when the LocalPlayer()'s physgun is physgunning an entity. 
-- On server, it's only run once on physgun drop.
function ENTITY:CalcSnappingPoints(bReturnUnsnapped)
    local tSnapPoints = self:GetSnapPoints()
    if not tSnapPoints then return false end

    local oProperty = self:GetProperty()
    local tSnappedPoints = false
    local tUnsnappedPoints = {}
    local indicesToRemove = {}

    -- Gather all potential snap points
    for _, eEntity in pairs(oProperty:GetProps() or {}) do
        if not IsValid(eEntity) then continue end
        if eEntity == self then continue end

        local tOtherEntitySnapPoints = eEntity:GetSnapPoints()
        if not tOtherEntitySnapPoints then continue end

        for _, tOtherEntitySnapPoint in pairs(tOtherEntitySnapPoints) do
            table.insert(tUnsnappedPoints, {
                snapPoint = tOtherEntitySnapPoint,
                entity = eEntity,
                worldPoint = eEntity:LocalToWorld(tOtherEntitySnapPoint.point),
            })
        end
    end

    -- Find snaps for our entity
    for _, tSnapPoint in pairs(tSnapPoints) do
        local vSelfWorldPoint = self:LocalToWorld(tSnapPoint.point)

        for i, tPotentialSnap in ipairs(tUnsnappedPoints) do
            local eEntity = tPotentialSnap.entity
            local tOtherSnapPoint = tPotentialSnap.snapPoint

            local vOtherWorldPoint = eEntity:LocalToWorld(tOtherSnapPoint.point)

            if vSelfWorldPoint:DistToSqr(vOtherWorldPoint) < PLUGIN.config.snapDistanceSqr then
                tSnappedPoints = {
                    ours = {
                        snapPoint = tSnapPoint,
                        worldPoint = vSelfWorldPoint,
                        entity = self,
                    },
                    theirs = {
                        snapPoint = tOtherSnapPoint,
                        worldPoint = vOtherWorldPoint,
                        entity = eEntity,
                    },
                }

                table.insert(indicesToRemove, {selfIdx = #tUnsnappedPoints + 1, otherIdx = i})

                if not bReturnUnsnapped then
                    return tSnappedPoints
                end
            end
        end

        if bReturnUnsnapped then
            table.insert(tUnsnappedPoints, {
                snapPoint = tSnapPoint,
                entity = self,
                worldPoint = vSelfWorldPoint,
            })
        end
    end

    -- Remove snapped points from unsnapped points list
    for i = #indicesToRemove, 1, -1 do
        local pair = indicesToRemove[i]
        table.remove(tUnsnappedPoints, pair.selfIdx)
        table.remove(tUnsnappedPoints, pair.otherIdx)
    end

    return tSnappedPoints, tUnsnappedPoints
end

-- @TODO: This might not work for rotation in more than one axis. Test.
local function SnapToGrid(angle, grid)
    return (grid == 360) and 0 or math.Round(angle / grid) * grid
end

function ENTITY:CalcSnappingPos( vTargetPos, aTargetAng, tSnappedPoints )
    vTargetPos = vTargetPos or self:GetPos()
    aTargetAng = aTargetAng or self:GetAngles()

    local tOurSnapPoint = tSnappedPoints.theirs
    local tTheirSnapPoint = tSnappedPoints.ours

    -- Initial angles and grid
    local targetAng = tOurSnapPoint.entity:GetAngles()
    local angleGrid = tTheirSnapPoint.snapPoint.angleGrid

    -- Local angle difference
    local angleDiff = aTargetAng - targetAng
    angleDiff:Normalize()

    -- Snap angles
    angleDiff:SetUnpacked(
        SnapToGrid(angleDiff.p, angleGrid.p),
        SnapToGrid(angleDiff.y, angleGrid.y),
        SnapToGrid(angleDiff.r, angleGrid.r)
    )

    local finalAng = targetAng + angleDiff
    finalAng:Normalize()

    local mat = Matrix()
    mat:SetAngles(finalAng)
    local vSnapPoint2Local = tTheirSnapPoint.snapPoint.point
    local vSnapPoint2WorldAdjusted = mat * vSnapPoint2Local + self:GetPos()

    -- Calculate position offset
    local vSnapPoint1World = tOurSnapPoint.worldPoint
    local vAlignVector = vSnapPoint1World - vSnapPoint2WorldAdjusted

    return self:GetPos() + vAlignVector, finalAng
end

-- CalcZones is cached, so we can run it multiple times per tick without worrying about performance.
local tZonesCache = {}
local iZonesCacheTick = 0
function ENTITY:CalcZones( vTargetPos, aTargetAng )
    if iZonesCacheTick == engine.TickCount() then
        if tZonesCache[ self:EntIndex() ] then return tZonesCache[ self:EntIndex() ] end
    else
        tZonesCache = {}
        iZonesCacheTick = engine.TickCount()
    end


    if not self:GetProperty() then return end
    local oProperty = self:GetProperty()

    local vHitBoxMin, vHitBoxMax = self:GetCollisionBounds()

    vTargetPos = vTargetPos or self:GetPos()
    aTargetAng = aTargetAng or self:GetAngles()

    local tZonesInside = {}


    for _, tZone in pairs( oProperty:GetZones() ) do
        local vZoneMidpoint = ( tZone.pos[ 1 ] + tZone.pos[ 2 ] ) / 2

        -- @TODO: We should really be doing this at the property setup config level.
        local vZoneSize = Vector(
            math.abs(tZone.pos[1].x - tZone.pos[2].x) / 2,
            math.abs(tZone.pos[1].y - tZone.pos[2].y) / 2,
            math.abs(tZone.pos[1].z - tZone.pos[2].z) / 2
        )

        local bIntersectingZone = util.IsOBBIntersectingOBB(
            vTargetPos,
            aTargetAng,
            vHitBoxMin,
            vHitBoxMax,
            vZoneMidpoint,
            Angle(0, 0, 0),
            -vZoneSize,
            vZoneSize,
            0
        )

        if bIntersectingZone then
            table.insert( tZonesInside, tZone )
        end
    end

    tZonesCache[ self:EntIndex() ] = tZonesInside

    return tZonesInside
end

function ENTITY:IsInZoneOfType( sType, vTargetPos, aTargetAng )
    local tZones = self:CalcZones()
    if not tZones then return false end

    for _, tZone in pairs( tZones ) do
        if tZone.type == sType then return true end
    end

    return false
end

function ENTITY:CalcIntersect(vTargetPos, aTargetAng, tFilter)
    if not self:GetProperty() then return end

    vTargetPos = vTargetPos or self:GetPos()
    aTargetAng = aTargetAng or self:GetAngles()

    local vOBBMins, vOBBMaxs = self:OBBMins(), self:OBBMaxs()
    local iBoundingRadius = self:BoundingRadius()

    -- @TODO: This isn't really perfect, but it's good enough for now.
    local vAbsMax = Vector(
        iBoundingRadius,
        iBoundingRadius,
        iBoundingRadius
    )
    vAbsMax:Mul(2)

    local tEntitiesInBox = ents.FindInBox(vTargetPos - vAbsMax, vTargetPos + vAbsMax)

    local tIntersectingEntities = {}

    -- Loop through and refine collision check
    for _, ent in ipairs(tEntitiesInBox) do
        if ent == self then continue end
        if not ent:IsSolid() then continue end
        if tFilter and tFilter[ent:EntIndex()] then continue end

        local entPos = ent:GetPos()
        local entAng = ent:GetAngles()
        local entMins, entMaxs = ent:OBBMins(), ent:OBBMaxs()

        -- Use util.IsOBBIntersectingOBB for precise collision check
        local isIntersecting = util.IsOBBIntersectingOBB(
            vTargetPos, aTargetAng, vOBBMins, vOBBMaxs,
            entPos, entAng, entMins, entMaxs,
            0  -- Tolerance, you can adjust this value
        )

        if isIntersecting then
            table.insert(tIntersectingEntities, ent)
        end
    end

    return tIntersectingEntities
end

function ENTITY:CalcFloor(vTargetPos, aTargetAng)
    if not self:GetProperty() then return end
    local oProperty = self:GetProperty()
    if not self:GetCategory() then return end
    local oCategory = self:GetCategory()

    vTargetPos = vTargetPos or self:GetPos()
    aTargetAng = aTargetAng or self:GetAngles()

    if string.StartsWith( oCategory:GetID(), "defensive_props" ) and oProperty:GetFloorZ() then
        vTargetPos.z = oProperty:GetFloorZ()
    end

    return vTargetPos, aTargetAng
end