local PLUGIN = PLUGIN

local PLY = FindMetaTable("Player")

-- Handcuffs

function PLY:Handcuff()
    -- if self:IsRestricted() then return end

    self:SetRestricted( true, true )
    self:SetNetVar( "handcuffed", true )

    -- Because tazers. This is a hacky fix, but it works.
    timer.Simple( 0, function()
        self:Give( "prp_cuffed", true )
        self:SelectWeapon( "prp_cuffed" )
    end )
end

function PLY:Uncuff()
    -- if not self:IsRestricted() then return end

    self:SetRestricted( false, true )
    self:SetNetVar( "handcuffed", false )

    self:StripWeapon( "prp_cuffed" )

    -- Realistic_Police.ResetBonePosition(Realistic_Police.ManipulateBoneCuffed, self)
    Realistic_Police.StopDrag( self )
end

-- Dragging

function PLY:ForceIntoVehicle( vVehicle, pOfficer )
    local tSeats = vVehicle:VC_getSeatsAvailable()
    pOfficer = pOfficer or self:GetDragged()

    if #tSeats == 0 then
        pOfficer:Notify( "The vehicle is full!" )
        return false
    end

    self:EnterVehicle( tSeats[#tSeats] )

    Realistic_Police.StopDrag( self )
end

-- Tazing

ix.config.Add( "tazeTime", 5, "How long a player should be tazed for.", nil, {
    data = { min = 1, max = 30 },
    category = "Palomino: Police"
} )

function PLY:Taze( pOfficer )
    if not IsValid(self) or not self:IsPlayer() then return end 

    if self:GetNetVar("draggedBy", NULL) then
        self:GetNetVar("draggedBy", NULL):SetNetVar("dragging", NULL)
        self:SetNetVar("draggedBy", false)
    end

    local iTazeTime = ix.config.Get( "tazeTime", 5 )

    self:SetNetVar( "tazed", true )
    self:SetRagdolled( true, iTazeTime, iTazeTime )

    timer.Simple( iTazeTime, function()
        if not IsValid( self ) then return end

        self:SetNetVar( "tazed", false )
    end )
end

-- @TODO: Move to hooks file
hook.Add( "OnCharacterFallover", "PRP.Police.OnCharacterFallover", function( pPlayer, eRagdoll, bIsRagdolled )
    if not IsValid( pPlayer ) or not IsValid( eRagdoll ) then return end

    if pPlayer:IsHandcuffed() then
        eRagdoll:CallOnRemove( "handcuff", function()
            if not IsValid( pPlayer ) then return end

            print("still run")

            pPlayer:Handcuff()
        end )
    end
end )