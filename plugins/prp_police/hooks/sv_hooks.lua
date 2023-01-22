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

util.AddNetworkString( "PRP.Police.IssueTicket" )
net.Receive( "PRP.Police.IssueTicket", function( _, pOfficer )
    local pVictim = net.ReadEntity()
    local iAmount = net.ReadInt( 32 )
    local sReason = net.ReadString()

    if not pOfficer:GetCharacter() then return end

    local bSuccess, sMessage = pOfficer:GetCharacter():IssueTicket( pVictim, sReason, iAmount )
    pOfficer:Notify( sMessage )
end )