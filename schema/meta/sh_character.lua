local CHAR = ix.meta.character

function CHAR:IsPolice()
	return self:GetFaction() == FACTION_POLICE
end