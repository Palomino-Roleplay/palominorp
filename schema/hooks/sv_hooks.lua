function Schema:InitializedPlugins()
    -- Disable some plugins
    local tDisabledPlugins = {
        ["recognition"] = true,
        ["stamina"] = true,
        ["strength"] = true
    }

    local bShouldRestart = false
    for sPlugin, _ in pairs( tDisabledPlugins ) do
        if ( ix.plugin.Get( sPlugin ) ) then bShouldRestart = true end

        ix.plugin.SetUnloaded( sPlugin, true )
    end

    if bShouldRestart then
        -- @TODO: Consider making a better server log thing.
        Print( "Detected default plugins that need to be disabled. Disabling and restarting..." )

        -- Give a second for the data file to update.
        timer.Simple( 1, function() RunConsoleCommand("changelevel", game.GetMap()) end )
    end

    -- Disable giving CW 2.0 attachments on spawn
    for key, attData in ipairs(CustomizableWeaponry.registeredAttachments) do
		game.ConsoleCommand(attData.cvar .. " 0\n")
	end
end

function Schema:PlayerCanHearPlayersVoice( pListener, pTalker )
    if not pTalker:Alive() or not pListener:Alive() then
        return false, false
    end
end

function Schema:PlayerUse(client, entity)
	if (client:IsRestricted() or (isfunction(entity.GetEntityMenu) and entity:GetClass() != "ix_item" and not entity:IsVehicle())) then
		return false
	end

	return true
end

function Schema:PlayerJoinedClass( pPlayer, iNewClass, iOldClass )
    local tOldClass = ix.class.Get( iOldClass )
    local tNewClass = ix.class.Get( iNewClass )

    -- @TODO: Ew.
    for _, sWeapon in pairs( tOldClass.weapons or {} ) do
        pPlayer:StripWeapon( sWeapon )
    end

    for _, sWeapon in pairs( tNewClass.weapons or {} ) do
        pPlayer:Give( sWeapon )
    end
end

local tWhitelist = {
    "76561198072551027", -- sil
    "76561197997304089", -- Knight
    "0",

    -- Playtesters
    "76561198139507705", -- ZakisMal
    "76561198030695593", -- tone
    "76561199117143435", -- puvz
    "76561198159973012", -- Wolv
    "76561198352665638", -- Sudzy
    "76561198241491232", -- Du$ty
    "76561198002150852", -- gregg
}

function Schema:CheckPassword( sSteamID64, sIPAddress, sSVPassword, sCLPassword, sName )
    if not PRP.API.bInitialized then
        return false, "Palomino is still initializing. Please wait a few seconds and try again."
    end

    local sSteamID = util.SteamIDFrom64( sSteamID64 )

    if PRP.API.ServerInfo.whitelist and not PRP.API.ServerInfo.whitelist[ sSteamID ] then
        return false, "Sorry, " .. sName .. ", you are not whitelisted for this Palomino server."
    end

    PRP.API.WS.Send( "player/join", {
        steamID = sSteamID,
        steamName = sName,
    } )
end

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "PRP:PlayerDisconnected", function( tData )
    PRP.API.WS.Send( "player/leave", {
        steamID = tData.networkid,
        sReason, tData.reason
    } )
end )

-- @TODO: Somewhere in the gamemode we're changing the hitgroup scales, but I can't find where.
-- For now, the left number sets the damage to the base damage, and the right number is our multiplier.

-- TLDR: Don't touch the left number.
local tHitgroupsScale = {
    [HITGROUP_GENERIC] = 1 * 1,
    [HITGROUP_HEAD] = 0.5 * 2,
    [HITGROUP_CHEST] = 1 * 1,
    [HITGROUP_STOMACH] = 1 * 1,
    [HITGROUP_LEFTARM] = 4 * 1,
    [HITGROUP_RIGHTARM] = 4 * 1,
    [HITGROUP_LEFTLEG] = 4 * 0.5,
    [HITGROUP_RIGHTLEG] = 4 * 0.5,
    [HITGROUP_GEAR] = 1
}

function Schema:ScalePlayerDamage( pPlayer, iHitGroup, tDamageInfo )
    local iScale = tHitgroupsScale[ iHitGroup ] or 1

    tDamageInfo:ScaleDamage( iScale )

    if iHitGroup == HITGROUP_HEAD then
        pPlayer:EmitSound( "player/headshot" .. math.random( 1, 2 ) .. ".wav" )
    end
end

local HELIX = baseclass.Get( "gamemode_helix" )
HELIX.PlayerUse = nil