local PLY = FindMetaTable("Player")

function PLY:IsCP()
    return self:GetCharacter():IsPolice()
end

function PLY:IsArrested()
    return self:GetCharacter():IsArrested()
end

function PLY:isArrested()
    return self:IsArrested()
end