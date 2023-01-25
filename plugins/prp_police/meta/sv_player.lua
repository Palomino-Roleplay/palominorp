local PLUGIN = PLUGIN

local PLY = FindMetaTable("Player")

-- Handcuffs

function PLY:Handcuff()
    if self:IsRestricted() then return end

    self:SetRestricted( true, true )
    self:SetNetVar( "handcuffed", true )

    local wCuffs = self:Give( "prp_cuffed", true )
    self:SelectWeapon( "prp_cuffed" )

	for k,v in pairs(Realistic_Police.ManipulateBoneCuffed) do
		local bone = self:LookupBone(k)
		if bone then
			self:ManipulateBoneAngles(bone, v)
		end
	end
end

function PLY:Uncuff()
    if not self:IsRestricted() then return end

    self:SetRestricted( false, true )
    self:SetNetVar( "handcuffed", false )

    self:StripWeapon( "prp_cuffed" )

    Realistic_Police.ResetBonePosition(Realistic_Police.ManipulateBoneCuffed, self)
    Realistic_Police.StopDrag( self )
end