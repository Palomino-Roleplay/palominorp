function Schema:CanPlayerUseBusiness()
    return false
end

function Schema:CanPlayerJoinClass()
    return false
end

function Schema:PlayerInitialSpawn( pPlayer )
    -- @TODO: Move this to a better place
    pPlayer:SetCanZoom( false )
end