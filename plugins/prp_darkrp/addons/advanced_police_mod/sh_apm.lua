-- @TODO: Wanted system with DarkRPVarChanged and getDarkRPVar("wanted"), "warrant", "warrantReason", "bailAvailable" etc.
-- @TODO: darkrp unwarrant concommand and darkrp warrant concommand support
-- @TODO: what is DarkRPVar bailAvailable?
    -- See DarkRP.registerDarkRPVar for "warrant", "warrantReason", and "bailAvailable"

local PLY = FindMetaTable("Player")

function PLY:PM_IsPolice()
    return self:GetCharacter() and self:GetCharacter():IsPolice()
end

function PLY:PM_IsChief()
    return self:GetCharacter() and self:GetCharacter():GetClass() == CLASS_POLICE_CHIEF
end