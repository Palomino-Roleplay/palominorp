PRP = PRP or {}
PRP.Vehicle = PRP.Vehicle or {}

PRP.Vehicle.Job = PRP.Vehicle.Job or {}
PRP.Vehicle.Job.List = PRP.Vehicle.Job.List or {}

function PRP.Vehicle.Job.Register( sVehicleID, tOverrides )
    local tVehiclesList = list.Get( "Vehicles" )
    local tVehicleData = tVehiclesList[sVehicleID]

    if not tVehicleData then
        Print( "Failed to get vehicle data when registering job vehicle for vehicle ID: " .. sVehicleID )
        return
    end

    -- @TODO: Add support for class-based vehicles
    -- @TODO: Maybe VC_ExtraSeats in this table can be edited to add more seats to some vehicles.

    PRP.Vehicle.Job.List[sVehicleID] = table.Merge( {
        Name = tVehicleData.Name,
        Model = tVehicleData.Model,
        Factions = {}
    }, tOverrides )
end

function PRP.Vehicle.Job.Get( sVehicleID )
    return PRP.Vehicle.Job.List[sVehicleID]
end

function PRP.Vehicle.Job.GetAll()
    return PRP.Vehicle.Job.List
end

function PRP.Vehicle.Job.GetByFaction( iFactionID )
    -- @TODO: Consider making a new table for this, so we don't have to loop through all vehicles every time.
    local tVehicles = {}

    for sVehicleID, tVehicleData in pairs( PRP.Vehicle.Job.List ) do
        if tVehicleData.Factions[iFactionID] then
            tVehicles[sVehicleID] = tVehicleData
        end
    end

    return tVehicles
end

-- @TODO: Move to a config or something
PRP.Vehicle.Job.Register( "07sgmcrownviccvpi", {
    Factions = {
        [FACTION_POLICE] = true
    }
} )

PRP.Vehicle.Job.Register( "chev_impala_09_police", {
    Factions = {
        [FACTION_POLICE] = true
    }
} )