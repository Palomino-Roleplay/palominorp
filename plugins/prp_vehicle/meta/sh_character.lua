local CHAR = ix.meta.character

function CHAR:GetJobVehicle()
    return self._jobVehicle
end

function CHAR:HasJobVehicle()
    return self._jobVehicle != nil
end