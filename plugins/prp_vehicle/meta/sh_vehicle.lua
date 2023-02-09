local VEHICLE = FindMetaTable("Vehicle")

function VEHICLE:IsPoliceVehicle()
    return self:GetNetVar( "policeVehicle", false )
end

-- function VEHICLE:CPPIGetOwner()
--     Print("run?")
--     return ix.char.loaded[self:GetNetVar("owner", 0)]
-- end