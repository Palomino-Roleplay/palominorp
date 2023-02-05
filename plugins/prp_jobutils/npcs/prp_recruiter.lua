NPC.name = "Job Recruiter"
NPC.description = "Job Recruiter NPC"
NPC.networkUse = true

AccessorFunc( NPC, "_faction", "Faction" )

function NPC:Init()
end

if CLIENT then
    function NPC:OnUse()
        local dJobMenu = vgui.Create( "PRP.Job.Menu" )
        dJobMenu:SetFaction( self:GetFaction() )
    end
end

function NPC:OnSpawn()
end

function NPC:GetTitle( eEntity )
    local iFaction = self:GetFaction()

    if not iFaction then
        return "Job Recruiter"
    end

    return ix.faction.indices[iFaction].name .. " Recruiter"
end

function NPC:GetSubtitle()
end