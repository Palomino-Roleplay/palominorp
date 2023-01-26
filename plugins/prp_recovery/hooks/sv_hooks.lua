local PLUGIN = PLUGIN

local HELIX = baseclass.Get( "gamemode_helix" )
HELIX.PlayerDeathThink = nil

function PLUGIN:PlayerDeathThink( pPlayer )
	if (pPlayer:GetCharacter()) then
		local deathTime = pPlayer:GetNetVar("deathTime")

		if (deathTime and deathTime <= CurTime()) then
            pPlayer:DeathSpawn()
			-- pPlayer:Spawn()
		end
	end

	return false
end