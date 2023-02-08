PRP = PRP or {}
PRP.Vehicle = PRP.Vehicle or {}

-- https://github.com/Facepunch/garrysmod/blob/6f9183214e69a8ca3c58b546062aac28eb9dc4e5/garrysmod/gamemodes/sandbox/gamemode/commands.lua#L944
function PRP.Vehicle.Spawn( sVehicleID, vPos, aAng )
    local tVehiclesList = list.Get( "Vehicles" )
    local tVehicleData = tVehiclesList[sVehicleID]

    if not tVehicleData then return end

    local eVehicle = ents.Create( tVehicleData.Class )
    if not IsValid( eVehicle ) then return end

    duplicator.DoGeneric( eVehicle, tVehicleData )

    if ( tVehicleData and tVehicleData.KeyValues ) then
		for k, v in pairs( tVehicleData.KeyValues ) do

			local kLower = string.lower( k )

			if ( kLower == "vehiclescript" or
				 kLower == "limitview"     or
				 kLower == "vehiclelocked" or
				 kLower == "cargovisible"  or
				 kLower == "enablegun" )
			then
				eVehicle:SetKeyValue( k, v )
			end

		end
	end

    eVehicle:SetPos( vPos )
    eVehicle:SetAngles( aAng )

    eVehicle:Spawn()
    eVehicle:Activate()

    eVehicle:DropToFloor()

    if ( tVehicleData && tVehicleData.ColGroup ) then Ent:SetCollisionGroup( tVehicleData.ColGroup ) end

    eVehicle.VehicleTable = tVehicleData

    return eVehicle
end

function PRP.Vehicle.Remove( vVehicle )
    if not IsValid( vVehicle ) then return end

    vVehicle:Remove()
end

concommand.Add( "prp_dev_spawncopcar", function( pPlayer )
    if not pPlayer:IsDeveloper() then return end

    local tSpots = PRP.Vehicle.Parking.GetAvailable( "police_garage" )
    Print( tSpots )
    if not tSpots then
        pPlayer:Notify( "Could not find free parking spot." )
        return
    end

    local tTestPos = tSpots
    local vVehicle = PRP.Vehicle.Spawn( "07sgmcrownviccvpi", tTestPos.midpoint, tTestPos.ang )

    undo.Create( "Vehicle" )
        undo.SetPlayer( pPlayer )
        undo.AddEntity( vVehicle )
    undo.Finish()

    pPlayer:AddCleanup( "vehicles", vVehicle )
end )

concommand.Add( "prp_dev_spawnJobVehicle", function( pPlayer )
    if not pPlayer:IsDeveloper() then return end

    pPlayer:GetCharacter():SpawnJobVehicle()
end )