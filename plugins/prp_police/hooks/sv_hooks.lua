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
    if not IsValid( pVictim ) then return end
    if not pVictim:GetCharacter() then return end
    if not pOfficer:GetCharacter():IsPolice() then return end
    -- @TODO: Get that catch-all function (if they're restrained, not alive, etc.)
    if not pOfficer:Alive() then return end
    -- @TODO: Not the best strategy. Any player can just run away and avoid a ticket. (Fake TODO)
    if pOfficer:GetPos():DistToSqr( pVictim:GetPos() ) >= 100000 then return end

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

-- Police garages

-- @TODO: Move to library
local function DoorIsOpen( door )
	local doorClass = door:GetClass()

	if ( doorClass == "func_door" or doorClass == "func_door_rotating" ) then

		return door:GetInternalVariable( "m_toggle_state" ) == 0

	elseif ( doorClass == "prop_door_rotating" ) then

		return door:GetInternalVariable( "m_eDoorState" ) ~= 0

	else

		return false

	end
end

-- @TODO: Move this to a config file
PLUGIN.Garages = {
    ["rp_riverden_v1a"] = {
        -- Police Garage
        2020,
        2023,
        -- Fire Department
        3189,
        3188
    }
}

function PLUGIN:PlayerButtonDown( pPlayer, iButton )
    if pPlayer._nextGarageCheck and pPlayer._nextGarageCheck > CurTime() then return end
    if iButton ~= KEY_LSHIFT then return end
    if not pPlayer:InVehicle() then return end
    local vVehicle = pPlayer:GetVehicle()
    if not vVehicle:IsPoliceVehicle() then return end

    local vPos = vVehicle:GetPos()

    for _, iGarageID in pairs( self.Garages[game.GetMap()] or {} ) do
        local eGarage = ents.GetMapCreatedEntity( iGarageID )
        if not IsValid( eGarage ) then continue end
        if vPos:DistToSqr( eGarage:GetPos() ) > 500000 then continue end

        pPlayer:EmitSound( "buttons/button24.wav" )
        pPlayer._nextGarageCheck = CurTime() + 2

        local bIsOpen = DoorIsOpen( eGarage )
        eGarage:Fire( bIsOpen and "Close" or "Open" )

        if not bIsOpen then
            timer.Simple( 7, function()
                eGarage:Fire( "Close" )
            end )
        end

        break
    end
end