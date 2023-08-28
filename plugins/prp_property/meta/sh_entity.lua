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
function ENTITY:CalcSnapping(bReturnUnsnapped)
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

