local PLUGIN = PLUGIN

function PLUGIN:PlayerSpawnProp( pPlayer, sModel )
    -- if pPlayer:IsAdmin() then
    --     return true
    -- end

    local iCooldown = ix.config.Get( "propertySpawnmenuCooldown", 1 )

    if pPlayer.m_iLastSpawnmenu and pPlayer.m_iLastSpawnmenu > CurTime() then
        pPlayer:Notify( "You must wait " .. math.ceil( pPlayer.m_iLastSpawnmenu - CurTime() ) .. " seconds before using the spawnmenu again." )
        return false
    end
    pPlayer.m_iLastSpawnmenu = CurTime() + iCooldown

    if not pPlayer:GetCharacter() then return end
    local cCharacter = pPlayer:GetCharacter()

    -- @TODO: Base this on properties the player has *access* to.
    local tProperties = cCharacter:GetRentedProperties()

	local tTrace = util.TraceLine( {
        start = pPlayer:GetShootPos(),
        endpos = pPlayer:GetShootPos() + ( pPlayer:GetAimVector() * 2048 ),
        filter = pPlayer
    } )

    if not tTrace.Hit then return false end

    local oPropertyInside = false
    for _, oProperty in pairs( tProperties ) do
        if oProperty:Contains( pPlayer:GetPos() ) and oProperty:Contains( tTrace.HitPos ) then
            oPropertyInside = true
            break
        end
    end

    if not oPropertyInside then
        pPlayer:Notify( "You cannot currently spawn props outside of your property." )
        return false
    end

    -- return true
end

function PLUGIN:PlayerSpawnedProp( pPlayer, sModel, eEntity )
    -- @TODO: ICKY ICKY UGLY. There has to be a better way.
    local tProperties = pPlayer:GetCharacter():GetRentedProperties()
    for _, oProperty in pairs( tProperties ) do
        if oProperty:Contains( pPlayer:GetPos() ) then
            eEntity:SetProperty( oProperty )
            break
        end
    end
end