local PLUGIN = PLUGIN

local PLY = FindMetaTable("Player")

-- Handcuffs

function PLY:Handcuff()
    if self:IsRestricted() then return end

    self:SetRestricted( true, true )
    self:SetNetVar( "handcuffed", true )

    local wCuffs = self:Give( "prp_cuffed", true )
    self:SetActiveWeapon( wCuffs )
end

function PLY:Uncuff()
    if not self:IsRestricted() then return end

    self:SetRestricted( false, true )
    self:SetNetVar( "handcuffed", false )

    self:StripWeapon( "prp_cuffed" )
end