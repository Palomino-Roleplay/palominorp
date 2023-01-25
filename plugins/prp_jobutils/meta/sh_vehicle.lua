local VEHICLE = FindMetaTable("Vehicle")

function VEHICLE:IsPoliceVehicle()
    -- @TODO: holy shit make this better
    return SERVER and self.ownedPlayer and self.ownedPlayer:IsPolice()
end

-- function VEHICLE:CPPIGetOwner()
--     Print("run?")
--     return ix.char.loaded[self:GetNetVar("owner", 0)]
-- end