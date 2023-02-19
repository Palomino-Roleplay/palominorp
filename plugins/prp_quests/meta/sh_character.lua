local PLUGIN = PLUGIN

local CHAR = ix.meta.character

function CHAR:CanActivateQuest( sQuestID )
    if self:GetActiveQuests()[sQuestID] then return false end
    if self:GetCompletedQuests()[sQuestID] then return false end
    -- @TODO: Check if the player is restricted, dead, etc.

    local tQuest = PRP.Quest.Get( sQuestID )

    if tQuest.requires then
        local tRequires = istable( tQuest.requires ) and tQuest.requires or { tQuest.requires }
        for _, sQuestID in ipairs( tRequires ) do
            if not self:GetCompletedQuests()[sQuestID] then
                return false
            end
        end
    end

    -- @TODO: Max active quests config? Do we even need one tbh?

    return true
end