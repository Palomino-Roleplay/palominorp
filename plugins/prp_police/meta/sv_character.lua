local PLUGIN = PLUGIN
local CHAR = ix.meta.character

-- Arresting

function CHAR:Arrest( pArrestor, iTime, sReason )
    if self:IsArrested() then return false, "Character is already arrested." end

    self:SetFaction( FACTION_PRISONER )

    local pPlayer = self:GetPlayer()

    pPlayer:StripWeapons()

    self:SetData( "arrest_time", iTime )

    self._arrestStart = CurTime()
    self._arrestTime = iTime

    timer.Create( "PRP.Arrest." .. self:GetID(), iTime, 1, function()
        self:Unarrest()
    end )

    pPlayer:SetPos( table.Random( PLUGIN.PrisonPositions ) )

    return true
end

function CHAR:Unarrest()
    if not self:IsArrested() then return false, "Character is not arrested." end

    self:SetFaction( FACTION_CITIZEN )

    -- @TODO: Setup unarrest positions or something.
    local pPrisoner = self:GetPlayer()
    if ( IsValid( pPrisoner ) ) then
        pPrisoner:Spawn()
    end

    self:SetData( "arrest_time", 0 )

    self._arrestStart = nil
    self._arrestTime = nil

    return true
end

function CHAR:GetArrestTimeRemaining()
    if not self._arrestStart or not self._arrestTime then return 0 end
    return self._arrestTime - ( CurTime() - self._arrestStart )
end
-- @TODO: For arrest histories, look into the sv_mysql in the libs/thirdparty folder in helix.

-- Warranting

function CHAR:Warrant( pOfficer, sReason, iTime )
    self:SetData( "warrant", sReason )

    timer.Create( "PRP.Warrant." .. self:GetID(), iTime, 1, function()
        if not self then return end
        self:Unwarrant( nil, "Warrant expired" )
    end )

    self:GetPlayer():Notify( "You have been issued a warrant by " .. pOfficer:Name() .. " for " .. sReason .. "." )
end

function CHAR:Unwarrant( pOfficer, sReason )
    self:SetData( "warrant", nil )

    self:GetPlayer():Notify( "Your warrant has been lifted: " .. sReason .. "." )
end

function CHAR:IsWarranted()
    return self:GetData( "warrant", nil ) ~= nil
end

-- Ticketing

function CHAR:Ticket( pOfficer, sReason, iAmount )
    local tTickets = self:GetTickets()
    tTickets[ os.time() ] = {
        officer = pOfficer:GetName(),
        reason = sReason,
        amount = iAmount,
        paid = false
    }
    self:SetTickets( tTickets )
end

function CHAR:PayTicket( iID )
    local tTickets = self:GetTickets()
    if not tTickets[ iID ] then return false, "Ticket does not exist." end
    if tTickets[ iID ].paid then return false, "Ticket is already paid." end
    if not self:HasMoney( tTickets[iID].amount ) then return false, "You do not have enough money to pay this ticket." end

    self:TakeMoney( tTickets[iID].amount )
    tTickets[ iID ].paid = os.time()
    self:SetTickets( tTickets )

    return true, "You paid off one of your tickets."
end

function CHAR:PayAllTickets()
    local tTickets, iTotalPrice = self:GetUnpaidTickets()

    if not tTickets then return false, "You do not have any unpaid tickets." end
    if not self:HasMoney( iTotalPrice ) then return false, "You do not have enough money to pay all of your tickets." end

    self:TakeMoney( iTotalPrice )
    for k, v in pairs( tTickets ) do
        v.paid = os.time()
    end
    self:SetTickets( tTickets )

    return true, "You paid off all of your tickets."
end