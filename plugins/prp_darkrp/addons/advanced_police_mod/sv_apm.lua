local CFG = VS_PoliceMod.Config

VS_PoliceMod.CopsPlayers = VS_PoliceMod.CopsPlayers or {}

hook.Remove( "OnPlayerChangedTeam", "OnPlayerChangedTeam.VS_PoliceMod" )
hook.Add("PlayerChangedTeam", "PlayerChangedTeam.VS_PoliceMod", function( pPlayer, iOldTeam, iNewTeam )
	local oldTeamCP = iOldTeam and ( ( GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[ iOldTeam ] ) or ( CFG.PoliceJobs[ team.GetName( iOldTeam ) ] ) )
	local newTeamCP = iNewTeam and ( ( GAMEMODE.CivilProtection and GAMEMODE.CivilProtection[ iNewTeam ] ) or ( CFG.PoliceJobs[ team.GetName( iNewTeam ) ] ) )

	if oldTeamCP and not newTeamCP then
		-- leave police
		VS_PoliceMod.CopsPlayers[ pPlayer ] = nil
	elseif not oldTeamCP and newTeamCP then
		-- join police
		VS_PoliceMod.CopsPlayers[ pPlayer ] = true
		hook.Run( "VS_PoliceMod.NewCop", pPlayer )
		VS_PoliceMod:NetStart("OnMissionsSync", VS_PoliceMod.CurrentPoliceCalls, pPlayer)
	end
end )