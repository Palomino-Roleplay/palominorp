local PLUGIN = PLUGIN
local CHAR = ix.meta.character

function CHAR:Arrest( pArrestor, iTime, sReason )
    self:SetFaction( FACTION_PRISONER )

    local pPrisoner = self:GetPlayer()

    pPrisoner:StripWeapons()

    self:SetData( "arrest_time", iTime )

    self._arrestStart = CurTime()
    self._arrestTime = iTime

    timer.Create( "PRP.Arrest." .. self:GetID(), iTime, 1, function()
        self:Unarrest()
    end )
end

function CHAR:Unarrest()
    self:SetFaction( FACTION_CITIZEN )

    -- @TODO: Setup unarrest positions or something.
    local pPrisoner = self:GetPlayer()
    if ( IsValid( pPrisoner ) ) then
        pPrisoner:Spawn()
    end

    self:SetData( "arrest_time", 0 )

    self._arrestStart = nil
    self._arrestTime = nil
end

function CHAR:GetArrestTimeRemaining()
    return self._arrestTime - ( CurTime() - self._arrestStart )
end

-- @TODO: For arrest histories, look into the sv_mysql in the libs/thirdparty folder in helix.