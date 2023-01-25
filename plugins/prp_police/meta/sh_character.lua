local CHAR = ix.meta.character

-- @TODO: Move
function CHAR:IsGovernment()
    return self:IsPolice()
end

-- Arresting

function CHAR:IsArrested()
    return self:GetFaction() == FACTION_PRISONER
end

-- Ticketing

function CHAR:GetTicket( iID )
    return self:GetTickets()[ iID ]
end

-- @TODO: Consider caching these two below
function CHAR:GetUnpaidTickets()
    local tTickets = self:GetTickets()
    local tUnpaid = {}
    local iTotal = 0

    for k, v in pairs( tTickets ) do
        if not v.paid then
            tUnpaid[ k ] = v
            iTotal = iTotal + v.amount
        end
    end

    return tUnpaid, iTotal
end

function CHAR:GetOverdueTickets()
    local iOverdueHours = ix.config.Get( "TicketOverdueTime", 24 * 3 )
    local tTickets = self:GetTickets()
    local tOverdue = {}

    for k, v in pairs( tTickets ) do
        if not v.paid and os.time() - k > iOverdueHours * 60 * 60 then
            tOverdue[ k ] = v
        end
    end

    return tOverdue
end

-- @TODO: Move to sh_player.lua
local PLY = FindMetaTable( "Player" )

function PLY:IsHandcuffed()
    -- @TODO: Return true only when handcuffed, not tied. (look at weapon maybe)
    return self:IsRestricted()
end