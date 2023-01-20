local PLUGIN = PLUGIN

function PLUGIN:CharacterPreSave( cChar )
    cChar:SetData( "arrest_time", cChar:GetArrestTimeRemaining() )
end

function PLUGIN:CanPlayerCombineItem( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerDropItem( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerEquipItem( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerInteractItem( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerOpenShipment( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerSpawnContainer( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerTakeItem( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerTradeWithVendor( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:CanPlayerUnequipItem( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return false end
end

function PLUGIN:PlayerSpawnObject( pPlayer )
    if pPlayer:GetCharacter():IsArrested() then return pPlayer:IsAdmin() end
end