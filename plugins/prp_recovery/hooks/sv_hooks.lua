local PLUGIN = PLUGIN

function PLUGIN:CanPlayerEnterVehicle( pPlayer, vVehicle, iSeatNumber )
    if pPlayer:IsRecovering() then return false end
end

function PLUGIN:CanExitVehicle( eVehicle, pPlayer )
    if pPlayer:IsRecovering() then return false end
end