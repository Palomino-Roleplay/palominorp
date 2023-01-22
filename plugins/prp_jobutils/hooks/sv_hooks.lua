local PLUGIN = PLUGIN

function PLUGIN:PlayerChangedTeam( pPlayer, iOldTeam, iNewTeam )
    local cCharacter = pPlayer:GetCharacter()
    if not cCharacter then return end

    if cCharacter:HasJobVehicle() then
        cCharacter:RemoveJobVehicle()
    end
end

-- @TODO: Remove on character/player change too.
