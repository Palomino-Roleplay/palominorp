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

-- Handcuffs

function PLUGIN:OnPlayerUnRestricted( pPlayer )
    if pPlayer._bIsHandcuffed then
        pPlayer._bIsHandcuffed = false
        pPlayer:Uncuff()
    end
end

-- Dragging

function PLUGIN:CanPlayerEnterVehicle( pPlayer, vVehicle, iSeat )
    -- if IsValid( pPlayer:GetNetVar( "draggedBy", NULL ) ) then return false end
    return true
end

function PLUGIN:PlayerEnteredVehicle( pPlayer, vVehicle, iSeat )
    local pDraggedPlayer = pPlayer:GetDragging()
    if IsValid( pDraggedPlayer ) then

        -- @TODO: Check that VCMod hasn't shat itself
        pDraggedPlayer:ForceIntoVehicle( vVehicle )
    end
end

function PLUGIN:PlayerLeaveVehicle( pPlayer )
    local pDraggedPlayer = pPlayer:GetDragging()
    if IsValid( pDraggedPlayer ) then
        pDraggedPlayer:ExitVehicle()
    end
end