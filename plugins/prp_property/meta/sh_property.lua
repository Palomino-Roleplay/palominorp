local PLUGIN = PLUGIN

local PROPERTY = {}

AccessorFunc( PROPERTY, "m_sID", "ID", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sName", "Name", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sCategory", "Category", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sDescription", "Description", FORCE_STRING )

AccessorFunc( PROPERTY, "m_bOwnable", "Ownable", FORCE_BOOL )
AccessorFunc( PROPERTY, "m_cOwner", "Owner" )

AccessorFunc( PROPERTY, "m_bRentable", "Rentable", FORCE_BOOL )
AccessorFunc( PROPERTY, "m_iRent", "Rent", FORCE_NUMBER )
AccessorFunc( PROPERTY, "m_cRenter", "Renter" )

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

                if SERVER then self:SetupDoor( eEntity ) end
            end

            eEntity:SetProperty( self )
        end
    end
end

function PROPERTY:HasAccess( pPlayer )
    if self:GetFactions() and self:GetFactions()[ pPlayer:GetFaction() ] then return true end
    if self:GetClasses() and self:GetClasses()[ pPlayer:GetClass() ] then return true end

    if self:GetRenter() == pPlayer:GetCharacter() then return true end
    if self:GetOwner() == pPlayer:GetCharacter() then return true end

    -- @TODO: Add support for giving access to other players

    return false
end

function PROPERTY:CanRent( pPlayer )
    if not pPlayer:GetCharacter() then return false, "You do not have a character." end
    if not self:GetRentable() then return false, "This property is not rentable." end
    -- @TODO: Check if this check works as intended with offline/unloaded characters
    if self:GetRenter() then return false, "This property is already rented." end

    local cCharacter = pPlayer:GetCharacter()

    -- Checking limits
    -- @TODO: These definitely need to be done differently in the future.
    -- @TODO: Test this
    if table.Count( cCharacter:GetRentedProperties() ) >= PLUGIN.config.limits.total then
        return false, "You have reached the maximum amount of properties you can rent."
    end

    if self:GetCategory() and table.Count( cCharacter:GetRentedPropertiesByCategory( self:GetCategory() ) ) >= PLUGIN.config.limits.category[ self:GetCategory() ] then
        return false, "You have reached the maximum amount of properties you can rent of this category."
    end

    if cCharacter:GetMoney() < self:GetRent() then
        return false, "You do not have enough money to rent this property."
    end

    return true
end

if SERVER then
    function PROPERTY:SetupDoor( eEntity )
        -- @TODO: Ugly. Have it support multiple factions.
        if self:GetFactions() then
            if self:GetPublicDoors() and eEntity:CreatedByMap() and self:GetPublicDoors()[eEntity:MapCreationID()] then
                eEntity:Fire("unlock")
                return
            end

            eEntity.ixFactionID = self:GetFactions()[1]
            eEntity:SetNetVar("faction", self:GetFactions()[1])
            eEntity:SetNetVar("visible", true)
            eEntity:SetNetVar("name", self:GetName())

            if self:GetLockOnStart() then
                eEntity:Fire("lock")
            end
        elseif self:GetRentable() then
            eEntity:SetNetVar("visible", true)
            eEntity:SetNetVar("name", self:GetName())
            eEntity:SetNetVar("ownable", true)

            if self:GetLockOnStart() then
                eEntity:Fire("lock")
            end
        end
    end

    function PROPERTY:Rent( pPlayer )
        local bCanRent, sReason = self:CanRent( pPlayer )
        if not bCanRent then
            pPlayer:Notify( sReason )
            return
        end

        self:SetRenter( pPlayer:GetCharacter() )
        pPlayer:GetCharacter():AddRentedProperty( self )

        -- @TODO: Add rent amount & interval to notification
        pPlayer:Notify( "You have rented " .. self:GetName() .. "!" )
    end

    function PROPERTY:UnRent( bSuppressNotification )
        -- @TODO: Make sure this works as intended (switching characters shouldn't send you the notification)
        if self:GetRenter() then
            self:GetRenter():RemoveRentedProperty( self )

            if not bSuppressNotification then
                self:GetRenter():GetPlayer():Notify( "Your rent agreement for " .. self:GetName() .. " has been terminated." )
            end
        end

        self:SetRenter( nil )

        -- Don't leave them stuck!
        for _, eEntity in ipairs( self:GetDoors() ) do
            eEntity:Fire( "unlock" )
        end
    end
elseif CLIENT then
    function PROPERTY:Rent()

    end

    function PROPERTY:UnRent()

    end
end

PRP.Property = PRP.Property or {}
PRP.Property.Meta = PROPERTY