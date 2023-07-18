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
end

local HELIX = baseclass.Get( "gamemode_helix" )
HELIX.PlayerUse = nil