local PLUGIN = PLUGIN

local PROPERTY = {}

AccessorFunc( PROPERTY, "m_sID", "ID", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sName", "Name", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sCategory", "Category", FORCE_STRING )
AccessorFunc( PROPERTY, "m_sDescription", "Description", FORCE_STRING )

AccessorFunc( PROPERTY, "m_bLeasable", "Leasable", FORCE_BOOL )
AccessorFunc( PROPERTY, "m_cLessee", "Lessee" )
AccessorFunc( PROPERTY, "m_iLesseeCharID", "LesseeCharID" )

AccessorFunc( PROPERTY, "m_bRentable", "Rentable", FORCE_BOOL )
AccessorFunc( PROPERTY, "m_iRent", "Rent", FORCE_NUMBER )
AccessorFunc( PROPERTY, "m_cRenter", "Renter" )

-- @TODO: Helper function: gets either Lessee or Renter.
AccessorFunc( PROPERTY, "m_cTenant", "Tenant" )

AccessorFunc( PROPERTY, "m_tFactions", "Factions" )
AccessorFunc( PROPERTY, "m_tClasses", "Classes" )

AccessorFunc( PROPERTY, "m_tSpawnEntities", "SpawnEntities" )
AccessorFunc( PROPERTY, "m_tBounds", "Bounds" )
AccessorFunc( PROPERTY, "m_tZones", "Zones" )

-- The Z value of the floor of the property (used to snap defense props to the floor)
AccessorFunc( PROPERTY, "m_iFloorZ", "FloorZ", FORCE_NUMBER )

AccessorFunc( PROPERTY, "m_tEntities", "Entities" )
AccessorFunc( PROPERTY, "m_tDoors", "Doors" )
AccessorFunc( PROPERTY, "m_tProps", "Props" )

AccessorFunc( PROPERTY, "m_tPermaProps", "PermaProps" )

AccessorFunc( PROPERTY, "m_bLockOnStart", "LockOnStart" )
AccessorFunc( PROPERTY, "m_tPublicDoors", "PublicDoors" )

function PROPERTY:Init()
    self:SetEntities( {} )
    self:SetDoors( {} )

    for _, tBound in pairs( self:GetBounds() or {} ) do
        for _, eEntity in pairs( ents.FindInBox( tBound[ 1 ], tBound[ 2 ] ) ) do
            table.insert( self:GetEntities(), eEntity )

            if eEntity:IsDoor() then
                table.insert( self:GetDoors(), eEntity )

                if SERVER then self:SetupDoor( eEntity ) end
            end

            eEntity:SetProperty( self )
        end
    end

    for _, tEntity in pairs( self:GetSpawnEntities() or {} ) do
        self:SpawnEntity( tEntity.class, tEntity.pos, tEntity.angles, nil, tEntity.callback )
    end

    for _, tPermaProp in pairs( self:GetPermaProps() or {} ) do
        self:SpawnEntity( "prop_physics", tPermaProp.pos, tPermaProp.angles, tPermaProp.model )
    end
end

function PROPERTY:GetTenant()
    return self:GetLessee() or self:GetRenter() or nil
end

function PROPERTY:GetOccupant()
    return self:GetTenant()
end

function PROPERTY:IsOccupied()
    return self:GetTenant() ~= nil
end

function PROPERTY:HasAccess( cCharacter )
    if self:GetFactions() and self:GetFactions()[ cCharacter:GetFaction() ] then return true end
    if self:GetClasses() and self:GetClasses()[ cCharacter:GetClass() ] then return true end

    if self:GetRenter() == cCharacter then return true end
    if self:GetLessee() == cCharacter then return true end

    -- @TODO: Add support for giving access to other players

    return false
end

function PROPERTY:CanRent( cCharacter )
    -- if not cCharacter then return false, "You do not have a character." end
    if not self:GetRentable() then return false, "This property is not rentable." end
    -- @TODO: Check if this check works as intended with offline/unloaded characters
    if self:IsOccupied() then return false, "This property is already occupied." end

    -- local cCharacter = pPlayer:GetCharacter()

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

function PROPERTY:Contains( vPosition )
    for _, tBound in ipairs( self:GetBounds() ) do
        if vPosition:WithinAABox( tBound[ 1 ], tBound[ 2 ] ) then
            return true
        end
    end

    return false
end

function PROPERTY:GetZonesOfType( sZoneType )
    local tZones = {}

    for _, tZone in ipairs( self:GetZones() ) do
        if tZone.type == sZoneType then
            table.insert( tZones, tZone )
        end
    end

    return tZones
end

function PROPERTY:GetZonesFromVector( vPosition )
    local tZones = {}

    for _, tZone in ipairs( self:GetZones() ) do
        if vPosition:WithinAABox( tZone.pos[ 1 ], tZone.pos[ 2 ] ) then
            table.insert( tZones, tZone )
        end
    end

    return tZones
end

function PROPERTY:GetZoneTypesFromVector( vPosition )
    local tZoneTypes = {}

    for _, tZone in ipairs( self:GetZonesFromVector( vPosition ) ) do
        table.insert( tZoneTypes, tZone.type )
    end

    return tZoneTypes
end

function PROPERTY:IsPositionInZoneType( vPosition, sZoneType )
    for _, sZone in ipairs( self:GetZoneTypesFromVector( vPosition ) ) do
        if sZone == sZoneType then
            return true
        end
    end

    return false
end

function PROPERTY:AddProp( eEntity )
    self.m_tProps = self.m_tProps or {}
    self.m_tEntities = self.m_tEntities or {}

    table.insert( self:GetProps(), eEntity )
    table.insert( self:GetEntities(), eEntity )

    eEntity:SetProperty( self )

    self.m_tPropsCategorized = self.m_tPropsCategorized or {}

    -- For a prop category (e.g.) decor_props/furniture/medium, add to following tables:
    -- decor_props
    -- decor_props/furniture
    -- decor_props/furniture/medium

    -- @TODO: Ass. This should be part of the category meta.
    local oPropCategory = eEntity:GetCategory()
    if not oPropCategory then return end

    local sCategoryID = oPropCategory:GetID()
    local tCategories = string.Explode( "/", sCategoryID )
    for i, oSubCategory in ipairs( tCategories ) do
        local sSubCategoryID = table.concat( tCategories, "/", 1, i )

        self.m_tPropsCategorized[ sSubCategoryID ] = self.m_tPropsCategorized[ sSubCategoryID ] or {}
        table.insert( self.m_tPropsCategorized[ sSubCategoryID ], eEntity )
    end

    if CLIENT then return true end

    -- @TODO: So we can't really network this immediately w/
    -- net library since it's done right at entity spawn.
    -- In the future though, we should definitely fix this.
    eEntity:SetNW2String( "PRP.Property", self:GetID() )

    return true
end

function PROPERTY:GetPropsByCategory( sCategory )
    self.m_tPropsCategorized = self.m_tPropsCategorized or {}

    return self.m_tPropsCategorized[ sCategory ] or {}
end

function PROPERTY:AddZone( tZoneData )
    self.m_tZones = self.m_tZones or {}

    table.insert( self.m_tZones, tZoneData )

    if SERVER then
        if string.StartsWith( tZoneData.type, "cinema" ) then
            if not tZoneData.screen then return end
            self:AddSpawnEntity( "mediaplayer_tv", tZoneData.screen.pos, tZoneData.screen.ang, function( eEntity )
                eEntity.m_tZoneData = tZoneData
                eEntity.m_bIsCinema = true
            end )
        end

        -- if tZoneData.type == "cinema_public" then
 
        -- elseif tZoneData.type == "cinema_playlist" then

        -- end
    end
end

if SERVER then
    function PROPERTY:SetupDoor( eEntity )
        if self:GetPublicDoors() and eEntity:CreatedByMap() and self:GetPublicDoors()[eEntity:MapCreationID()] then
            eEntity:Fire("unlock")
        elseif self:GetLockOnStart() then
            eEntity:Fire("lock")
        end

        -- @TODO: Ugly. Have it support multiple factions.
        if self:GetFactions() then
            eEntity.ixFactionID = self:GetFactions()[1]
            eEntity:SetNetVar("faction", self:GetFactions()[1])
            eEntity:SetNetVar("visible", true)
            eEntity:SetNetVar("name", self:GetName())
        elseif self:GetRentable() then
            eEntity:SetNetVar("visible", true)
            eEntity:SetNetVar("name", self:GetName())
            eEntity:SetNetVar("ownable", true)
        end
    end

    function PROPERTY:Rent( cCharacter )
        -- @TODO: Make sure players aren't renting/unrenting super fast (add a cooldown)
        local bCanRent, sReason = self:CanRent( cCharacter )
        if not bCanRent then
            cCharacter:GetPlayer():Notify( sReason )
            return
        end

        self:SetRenter( cCharacter )
        cCharacter:AddRentedProperty( self )

        -- @TODO: Add rent amount & interval to notification
        cCharacter:GetPlayer():Notify( "You have rented " .. self:GetName() .. "!" )

        self:Network()
    end

    function PROPERTY:UnRent( bSuppressNotification )
        -- @TODO: Make sure players aren't renting/unrenting super fast (add a cooldown)
        -- @TODO: Make sure this works as intended (switching characters shouldn't send you the notification)
        if self:GetRenter() then
            self:GetRenter():RemoveRentedProperty( self )

            if not bSuppressNotification then
                self:GetRenter():GetPlayer():Notify( "Your rent agreement for " .. self:GetName() .. " has been terminated." )
            end
        end

        self:SetRenter( nil )

        -- Don't leave them stuck!
        for _, eEntity in ipairs( self:GetDoors() or {} ) do
            eEntity:Fire( "unlock" )
        end

        -- Remove all props
        for _, eEntity in ipairs( self:GetProps() or {} ) do
            SafeRemoveEntity( eEntity )
        end

        self:Network()
    end

    function PROPERTY:Network( pPlayer )
        -- Don't update to individual players if the property isn't rented.
        -- if pPlayer and ( not self:GetRenter() ) then return end

        -- @TODO: Network this to newly joined players
        net.Start( "PRP.Property.Update" )
            net.WriteString( self:GetID() )

            -- @TODO: Perhaps send the character instead of the player?
            -- @TODO: Actually, maybe we shouldn't even tell the client who the renter is.
            net.WriteEntity( self:GetRenter() and self:GetRenter():GetPlayer() or NULL )
        if pPlayer then net.Send( pPlayer ) else net.Broadcast() end
    end

    function PROPERTY:AddSpawnEntity( sClass, vPos, aAngles, fnCallback )
        self.m_tSpawnEntities = self.m_tSpawnEntities or {}

        table.insert( self.m_tSpawnEntities, {
            class = sClass,
            pos = vPos,
            angles = aAngles,
            callback = fnCallback
        } )
    end

    function PROPERTY:SpawnEntity( sClass, vPos, aAngles, sModel, fnCallback )
        local eEntity = ents.Create( sClass )

        -- @TODO: Log this error well.
        if not IsValid( eEntity ) then return end

        if sModel then eEntity:SetModel( sModel ) end

        eEntity:SetPos( vPos )
        eEntity:SetAngles( aAngles )
        eEntity:SetProperty( self )

        self.m_tEntities = self.m_tEntities or {}
        table.insert( self.m_tEntities, eEntity )

        if fnCallback then fnCallback( eEntity ) end

        eEntity:Spawn()
        eEntity:Activate()

        local oPhysics = eEntity:GetPhysicsObject()
        if IsValid( oPhysics ) then
            oPhysics:EnableMotion( false )
        end

        return eEntity
    end
elseif CLIENT then
    function PROPERTY:Rent()

    end

    function PROPERTY:UnRent()

    end

    function PROPERTY:AddSpawnEntity()

    end

    function PROPERTY:SpawnEntity()

    end
end

PRP.Property = PRP.Property or {}
PRP.Property.Meta = PROPERTY