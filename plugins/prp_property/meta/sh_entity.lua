local ENTITY = FindMetaTable( "Entity" )

AccessorFunc( ENTITY, "m_pSpawner", "Spawner" )

function ENTITY:GetProperty()
    if self.m_oProperty then return self.m_oProperty end

    local sPropertyID = self:GetNWString( "PRP.Property", nil )
    if sPropertyID then
        self.m_oProperty = PRP.Property.Get( sPropertyID )
        return self.m_oProperty
    end

    return
end

function ENTITY:SetProperty( oProperty )
    if not oProperty then return end

    -- @TODO I'm sure we can do this better with our own networking
    self:SetNWString( "PRP.Property", oProperty:GetID() )
end

function ENTITY:HasAccess( cCharacter )
    if not cCharacter then return false end
    if not self:GetProperty() then return false end

    return self:GetProperty():HasAccess( cCharacter )
end



function ENTITY:SetCategory( tCategory )

end

function ENTITY:GetCategory()

end

function ENTITY:GetCategoryID()

end

function ENTITY:GetRootCategory()

end