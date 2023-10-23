local PLAYER = FindMetaTable("Player")

function PLAYER:IsPolice()
	return self:Team() == FACTION_POLICE
end

function PLAYER:IsDisguised()
	-- @TODO: FUck no
	return self:GetParts()["skullmask"] or self:GetParts()["black_balaclava"] or false
end