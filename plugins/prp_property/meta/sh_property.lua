local PROPERTY = {}

AccessorFunc( PROPERTY, "m_sID", "ID", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sName", "Name", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sDescription", "Description", FORCE_STRING )

AccessorFunc( PROPERTY, "m_bOwnable", "Ownable", FORCE_BOOL )
AccessorFunc( PROPERTY, "m_pOwner", "Owner" )

AccessorFunc( PROPERTY, "m_bRentable", "Rentable", FORCE_BOOL )
AccessorFunc( PROPERTY, "m_iRent", "Rent", FORCE_NUMBER )
AccessorFunc( PROPERTY, "m_pRenter", "Renter" )

AccessorFunc( PROPERTY, "m_tFactions", "Factions" )
AccessorFunc( PROPERTY, "m_tClasses", "Classes" )

AccessorFunc( PROPERTY, "m_tBounds", "Bounds" )

AccessorFunc( PROPERTY, "m_tEntities", "Entities" )
AccessorFunc( PROPERTY, "m_tDoors", "Doors" )

AccessorFunc( PROPERTY, "m_bLockOnStart", "LockOnStart" )
AccessorFunc( PROPERTY, "m_tPublicDoors", "PublicDoors" )

function PROPERTY:Init()
    self:SetEntities( {} )
    self:SetDoors( {} )

    for _, tBound in ipairs( self:GetBounds() ) do
        for _, eEntity in ipairs( ents.FindInBox( tBound[ 1 ], tBound[ 2 ] ) ) do
            table.insert( self:GetEntities(), eEntity )

            if eEntity:IsDoor() then
                table.insert( self:GetDoors(), eEntity )

                -- @TODO: Ugly. Have it support multiple factions.
                if SERVER and self:GetFactions() then
                    if self:GetPublicDoors() and eEntity:CreatedByMap() and self:GetPublicDoors()[eEntity:MapCreationID()] then
                        eEntity:Fire("unlock")
                        continue
                    end

                    eEntity.ixFactionID = self:GetFactions()[1]
                    eEntity:SetNetVar("faction", self:GetFactions()[1])
                    eEntity:SetNetVar("visible", true)
                    eEntity:SetNetVar("name", self:GetName())

                    if self:GetLockOnStart() then
                        eEntity:Fire("lock")
                    end
                end
            end

            eEntity:SetProperty( self )
        end
    end
end

function PROPERTY:HasAccess( pPlayer )
    if self:GetFactions() then
        if self:GetFactions()[ pPlayer:GetFaction() ] then return true end
    end

    if self:GetClasses() then
        if self:GetClasses()[ pPlayer:GetClass() ] then return true end
    end

    if self:GetOwner() == pPlayer then return true end
    if self:GetRenter() == pPlayer then return true end

    return false
end

PRP.Property = PRP.Property or {}
PRP.Property.Meta = PROPERTY