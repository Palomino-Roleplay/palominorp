local PLUGIN = PLUGIN

local PLY = FindMetaTable("Player")

-- Handcuffs

function PLY:Handcuff()
    if self:IsRestricted() then return end

    self:SetRestricted( true, true )
    self:SetNetVar( "handcuffed", true )

    local wCuffs = self:Give( "prp_cuffed", true )
    self:SelectWeapon( "prp_cuffed" )
end

function PLY:Uncuff()
    if not self:IsRestricted() then return end

    self:SetRestricted( false, true )
    self:SetNetVar( "handcuffed", false )

    self:StripWeapon( "prp_cuffed" )

    Realistic_Police.ResetBonePosition(Realistic_Police.ManipulateBoneCuffed, self)
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