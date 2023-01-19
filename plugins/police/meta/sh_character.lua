local CHAR = ix.meta.character

function CHAR:IsArrested()
    return self:GetFaction() == FACTION_PRISONER
end