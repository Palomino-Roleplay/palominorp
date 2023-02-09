PRP = PRP or {}
PRP.Vehicle = PRP.Vehicle or {}
PRP.Vehicle.Parking = PRP.Vehicle.Parking or {}

PRP.Vehicle.Parking.Lots = PRP.Vehicle.Parking.Lots or {}

-- Register a new "Parking Lot" for the vehicle system.
function PRP.Vehicle.Parking.Register( sParkingLot, tData )
    for iSpotID, tSpot in pairs( tData.Spots ) do
        tData.Spots[iSpotID].midpoint = ( tSpot.min + tSpot.max ) / 2
    end

    PRP.Vehicle.Parking.Lots[sParkingLot] = tData
end

-- Check if a parking spot is occupied.
function PRP.Vehicle.Parking.IsOccupied( tSpot )
    local tEntities = ents.FindInBox( tSpot.min, tSpot.max )

    for _, eEntity in pairs( tEntities ) do
        -- Let's trust whoever set up the parking lot to know what they're doing.
        if eEntity:CreatedByMap() then continue end

        if eEntity:IsVehicle() then return true end
        if IsValid( eEntity:GetPhysicsObject() ) then return true end

        return true
    end

    return false
end

-- Get the available parking spots in a parking lot.
function PRP.Vehicle.Parking.GetAvailableAll( sParkingLot, bReturnFirst )
    local tData = PRP.Vehicle.Parking.Lots[sParkingLot]
    if not tData then return false end

    local tSpots = {}

    for iSpotID, tSpot in pairs( tData.Spots ) do
        if PRP.Vehicle.Parking.IsOccupied( tSpot ) then continue end

        table.insert( tSpots, tSpot )

        if bReturnFirst then return tSpots end
    end

    return tSpots
end

-- Get an available parking spot in a parking lot.
function PRP.Vehicle.Parking.GetAvailable( sParkingLot )
    local tSpots = PRP.Vehicle.Parking.GetAvailableAll( sParkingLot, true )
    if not tSpots then return false end

    return tSpots[1]
end

-- Spawn vehicle helper with parking spots
-- @TODO: Move to serverside
function PRP.Vehicle.Parking.Spawn( sParkingLot, sVehicle )
    local tSpot = PRP.Vehicle.Parking.GetAvailable( sParkingLot )
    if not tSpot then
        return false, "There's no available parking spots!"
    end

    local eVehicle = PRP.Vehicle.Spawn( sVehicle, tSpot.midpoint, tSpot.ang )
    if not eVehicle then
        return false, "Failed to spawn vehicle!"
    end

    return eVehicle
end