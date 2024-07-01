function PLUGIN:InitializedPlugins()
    PRP.Vehicle.Parking.RegisterSinglePos( "prison", {
        Spots = {
            -- Left side (vehicle entrance view side), from back
            {
                pos = Vector( 9157, 8429, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9158, 8366, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9052, 8364, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9051, 8445, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9287, 8442, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9415, 8443, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9415, 8360, 200 ),
                ang = Angle( 0, 90, 0 )
            },
            {
                pos = Vector( 9285, 8359, 200 ),
                ang = Angle( 0, 90, 0 )
            },
        },
    } )
end

-- Restrict access to elevator to police

local tElevatorButtons = {
    [2889] = true, -- Lobby call button
    [2895] = true, -- Garage call button
    [2896] = true, -- Armory call button
    [2948] = true, -- Elevator 1st floor button
    [2898] = true, -- Elevator 2nd floor button
    [2899] = true, -- Elevator 3rd floor button
}

local tSoundCooldown = {}

if SERVER then
    function PLUGIN:PlayerUse( pPlayer, eEntity )
        if not eEntity:CreatedByMap() then return end
        if not pPlayer:GetCharacter() then return end

        if tElevatorButtons[eEntity:MapCreationID()] and not pPlayer:GetCharacter():IsGovernment() then
            if not tSoundCooldown[eEntity:EntIndex()] or tSoundCooldown[eEntity:EntIndex()] < CurTime() then
                eEntity:EmitSound( "buttons/button8.wav" )
                tSoundCooldown[eEntity:EntIndex()] = CurTime() + 2
            end

            return false
        end
    end
end