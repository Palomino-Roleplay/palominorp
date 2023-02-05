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

function Schema:PlayerUse(client, entity)
	if (client:IsRestricted() or (isfunction(entity.GetEntityMenu) and entity:GetClass() != "ix_item" and not entity:IsVehicle())) then
		return false
	end

	return true
end

local HELIX = baseclass.Get( "gamemode_helix" )
HELIX.PlayerUse = nil