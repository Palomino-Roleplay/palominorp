local PLAYER = FindMetaTable("Player")

function PLAYER:IsPolice()
	return self:Team() == FACTION_POLICE
end

function PLAYER:IsDisguised()
	return self:GetParts()["skullmask"] or false
end