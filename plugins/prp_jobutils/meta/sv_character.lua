local CHAR = ix.meta.character

function CHAR:SpawnJobVehicle( sVehicleID )
    if self:HasJobVehicle() then
        return false, "You already have a job vehicle!"
    end

    -- @TODO: Support other jobs as well.
    local vVehicle = PRP.Vehicle.Parking.Spawn( "police_garage", "07sgmcrownviccvpi", pPlayer )
    if not vVehicle then
        return false, "There was an error spawning your job vehicle!"
    end

    self._jobVehicle = vVehicle

    -- @TODO: Do this better

    vVehicle:SetNetVar( "owner", self:GetID() )
    vVehicle:SetNetVar( "policeVehicle", self:IsPolice() )
    vVehicle:CallOnRemove( "PRP.Vehicle.RemoveJobVehicle", function()
        self._jobVehicle = nil
    end )
    vVehicle:CPPISetOwner( self:GetPlayer() )

    return vVehicle, "Your job vehicle has been spawned!"
end

function CHAR:RemoveJobVehicle()
    if ( self._jobVehicle ) then
        PRP.Vehicle.Remove( self._jobVehicle )
        self._jobVehicle = nil
    end
end