local tDeathSounds = {
	Sound("vo/npc/male01/pain07.wav"),
	Sound("vo/npc/male01/pain08.wav"),
	Sound("vo/npc/male01/pain09.wav")
}

function PLUGIN:DoPlayerDeath( pPlayer, pAttacker, tDamageInfo )
	pPlayer:AddDeaths(1)

	if (hook.Run("ShouldSpawnpPlayerRagdoll", pPlayer) != false) then
		pPlayer:CreateRagdoll()
	end

    -- @TODO: Consider not doing frags to avoid gametracker-enabled dick measuring contest.
	if (IsValid(pAttacker) and pAttacker:IsPlayer()) then
		if (pPlayer == pAttacker) then
			pAttacker:AddFrags(-1)
		else
			pAttacker:AddFrags(1)
		end
	end

	net.Start("ixPlayerDeath")
	net.Send(pPlayer)

	-- pPlayer:SetAction("@respawning", ix.config.Get("spawnTime", 5))
	pPlayer:SetDSP(31)

    return true
end

function PLUGIN:PlayerDeath(pPlayer, eInflictor, eAttacker)
	local character = pPlayer:GetCharacter()

	if (character) then
		if (IsValid(pPlayer.ixRagdoll)) then
			pPlayer.ixRagdoll.ixIgnoreDelete = true
			pPlayer:SetLocalVar("blur", nil)

			if (hook.Run("ShouldRemoveRagdollOnDeath", pPlayer) != false) then
				pPlayer.ixRagdoll:Remove()
			end
		end

		pPlayer:SetNetVar("deathStartTime", CurTime() )
        pPlayer:SetNetVar("deathTimeFast", CurTime() + ix.config.Get("spawnTimeFast", 5))
		pPlayer:SetNetVar("deathTimeFull", CurTime() + ix.config.Get("spawnTimeFull", 30))

		character:SetData("health", nil)

		local deathSound = hook.Run("GetPlayerDeathSound", pPlayer)

		if (deathSound != false) then
			deathSound = deathSound or tDeathSounds[math.random(1, #tDeathSounds)]

			if (pPlayer:IsFemale() and !deathSound:find("female")) then
				deathSound = deathSound:gsub("male", "female")
			end

			pPlayer:EmitSound(deathSound)
		end

		local weapon = eAttacker:IsPlayer() and eAttacker:GetActiveWeapon()

		ix.log.Add(pPlayer, "playerDeath",
			eAttacker:GetName() != "" and eAttacker:GetName() or eAttacker:GetClass(), IsValid(weapon) and weapon:GetClass())
	end

    return true
end

function PLUGIN:PlayerDeathThink( pPlayer )
	if (pPlayer:GetCharacter()) then
        local iFastDeathTimestamp = pPlayer:GetNetVar("deathTimeFast")
		local iFullDeathTimestamp = pPlayer:GetNetVar("deathTimeFull")

        if iFastDeathTimestamp and iFastDeathTimestamp <= CurTime() and pPlayer:KeyDown( IN_JUMP ) then
            pPlayer:Spawn()
        elseif (iFullDeathTimestamp and iFullDeathTimestamp <= CurTime()) then
            pPlayer:Spawn()
		end
	end

	return false
end