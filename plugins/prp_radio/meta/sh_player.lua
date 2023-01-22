local PLY = FindMetaTable("Player")

function PLY:GetRadioChannel()
    return self:GetCharacter() and self:GetCharacter():GetRadioChannel()
end

function PLY:HasRadio()
    return self:GetCharacter() and self:GetCharacter():HasRadio()
end