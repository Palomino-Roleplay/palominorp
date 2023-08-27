local PLUGIN = PLUGIN

-- @TODO: Do staff limits & such
function PLUGIN:PlayerSpawnEffect( pPlayer, sModel )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.Effect" )
end

function PLUGIN:PlayerSpawnNPC( pPlayer, sNPCType, sWeapon )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.NPC" )
end

function PLUGIN:PlayerSpawnProp( pPlayer, sModel )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.Prop" )
end

function PLUGIN:PlayerSpawnRagdoll( pPlayer, sModel )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.Ragdoll" )
end

function PLUGIN:PlayerSpawnSENT( pPlayer, sClass )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.SENT" )
end

function PLUGIN:PlayerSpawnSWEP( pPlayer, sClass, tWeapon )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.SWEP" )
end

function PLUGIN:PlayerGiveSWEP( pPlayer, sClass, tWeapon )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.SWEP" )
end

function PLUGIN:PlayerSpawnVehicle( pPlayer, sModel, tVehicleTable )
    return CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.Spawn.Vehicle" )
end

-- @TODO: Find a better hook for this.
hook.Add( "InitializedPlugins", "PRP.Property.InitializedPlugins", function()
    local iRentInterval = ix.config.Get( "propertyRentPaymentInterval", 15 ) * 60

    timer.Create( "PRP.Property.RentPayments", iRentInterval, 0, function()
        for _, pPlayer in ipairs( player.GetAll() ) do
            if not pPlayer:GetCharacter() then continue end

            local cCharacter = pPlayer:GetCharacter()
            local iRent = 0

            for _, oProperty in pairs( cCharacter:GetRentedProperties() ) do
                iRent = iRent + oProperty:GetRent()
            end

            if iRent > 0 then
                -- @TODO: Possible way to exploit and achieve 1/2 rent by going back and forth between having and not having money. Not that big of a deal imo.
                -- @TODO: If player doesn't have enough money, kick them out of the property.
                if not cCharacter:HasMoney( iRent ) then
                    if cCharacter.m_bWarnedRent then
                        -- @TODO: Double for loop. Any way we can make this better?
                        for _, oProperty in pairs( cCharacter:GetRentedProperties() ) do
                            oProperty:UnRent()
                        end

                        pPlayer:Notify( "You don't have enough money to pay your rent. Your properties have been unrented." )
                        continue
                    end

                    pPlayer:Notify( "You don't have enough money to pay your rent. Your properties will be unrented in the next payment cycle." )
                    cCharacter.m_bWarnedRent = true
                    continue
                end

                cCharacter:TakeMoney( iRent, "rent" )
                pPlayer:Notify( "You have paid " .. ix.currency.Get( iRent ) .. " in rent." )
                cCharacter.m_bWarnedRent = false
            end
        end
    end )
end )

function PLUGIN:PlayerLoadedCharacter( pPlayer, cCurrent, cPrevious )
    if cPrevious then
        for _, oProperty in pairs( cPrevious:GetRentedProperties() ) do
            oProperty:UnRent( true )
        end
    end
end

function PLUGIN:PlayerDisconnected( pPlayer )
    if not pPlayer:GetCharacter() then return end

    for _, oProperty in pairs( pPlayer:GetCharacter():GetRentedProperties() ) do
        oProperty:UnRent( true )
    end
end

function PLUGIN:PlayerInitialSpawn( pPlayer )
    -- @TODO: God can we please make this one net message?
    for _, oProperty in pairs( PRP.Property.GetAll() ) do
        oProperty:Network( pPlayer )
    end
end

-- F2 hook
function PLUGIN:ShowTeam( pPlayer )
    if not pPlayer:GetCharacter() then return end
    local cCharacter = pPlayer:GetCharacter()

    local tTrace = util.TraceLine( {
        start = pPlayer:GetShootPos(),
        endpos = pPlayer:GetShootPos() + pPlayer:GetAimVector() * 96,
        filter = pPlayer
    } )

    local eEntity = tTrace.Entity
    if not IsValid( eEntity ) or not eEntity:IsDoor() then return end

    local oProperty = eEntity:GetProperty()
    if not oProperty then return end

    if oProperty:GetRenter() then
        -- @TODO: Open property menu
        oProperty:UnRent()
    else
        -- Attempt to rent the property.
        oProperty:Rent( cCharacter )
    end
end