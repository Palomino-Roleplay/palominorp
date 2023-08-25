local ENTITY = FindMetaTable( "Entity" )

-- function ENTITY:CheckDoorAccess( pPlayer, iAccessType )

-- end

AccessorFunc( ENTITY, "m_oProperty", "Property" )
function ENTITY:GetProperty()
    if self.m_oProperty then return self.m_oProperty end

    local sPropertyID = self:GetNW2String( "PRP.Prop.Property", nil )
    if sPropertyID then
        self.m_oProperty = PRP.Property.Get( sPropertyID )
        return self.m_oProperty
    end

    return nil
end

AccessorFunc( ENTITY, "m_pSpawner", "Spawner" )