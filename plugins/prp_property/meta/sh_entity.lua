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