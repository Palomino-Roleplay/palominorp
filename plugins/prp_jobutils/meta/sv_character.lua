local CHAR = ix.meta.character

function CHAR:SpawnJobVehicle( sVehicleID )
    if self:HasJobVehicle() then
        return false, "You already have a job vehicle!"
    end

    -- @TODO: Find the parking spaces and al that crap
    local vVehicle = PRP.Vehicle.Spawn( "07sgmcrownviccvpi", Vector( -8130, 8137, -199 ), Angle( 0, 0, 0 ) )

    self._jobVehicle = vVehicle

    vVehicle:SetNetVar( "owner", self:GetID() )
    vVehicle:CallOnRemove( "PRP.Vehicle.RemoveJobVehicle", function()
        self._jobVehicle = nil
    end )
    vVehicle:CPPISetOwner( self:GetPlayer() )

    return true, "Your job vehicle has been spawned!"
end

function CHAR:RemoveJobVehicle()
    if ( self._jobVehicle ) then
        PRP.Vehicle.Remove( self._jobVehicle )
        self._jobVehicle = nil
    end
end