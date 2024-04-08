NPC.name = "Example NPC"
NPC.description = "An example NPC for you to use as a template."
NPC.networkUse = true

function NPC:Init()
end

if CLIENT then
    function NPC:OnUse( eEntity )
        -- local dJobMenu = vgui.Create( "PRP.Job.Menu" )
        -- dJobMenu:SetFaction( self:GetFaction() )
        -- Print( "KIL LMYSELF" )
        -- Print( eEntity )
        -- dJobMenu:SetNPC( eEntity )
    end
end

function NPC:OnSpawn()
end

function NPC:GetTitle( eEntity )
    -- local iFaction = self:GetFaction()

    -- if not iFaction then
    --     return "Job Recruiter"
    -- end

    -- return ix.faction.indices[iFaction].name .. " Recruiter"
end

function NPC:GetSubtitle()
end