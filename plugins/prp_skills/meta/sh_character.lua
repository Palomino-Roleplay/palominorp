local PLUGIN = PLUGIN

local CHAR = ix.meta.character

function CHAR:AddSkillXP( sSkillID, nXP )
    self:SetSkillXP( sSkillID, self:GetSkillXP( sSkillID ) + nXP )
end

function CHAR:GetSkillLevel( sSkillID )
    -- @TODO: Change
    return math.floor( self:GetSkillXP( sSkillID ) / 100 )
end

function CHAR:DoSkillXPChanged()
    print("skill xp changed")
end