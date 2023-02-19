local PLUGIN = PLUGIN

local CHAR = ix.meta.character

function CHAR:ActivateQuest( sQuestID )
    -- @TODO: Prolly wanna make better functions for this
    local tQuest = PRP.Quest.Get( sQuestID )
    if not tQuest then return false end

    if not self:CanActivateQuest( sQuestID ) then return false end

    -- @TODO: Disgusting. Ugly. Please do this one at a time instead of updating the entire table. PLEASE.
    -- @TODO: *WHEN* (not if) you redo this, only send the task detail (no need for requires info on the quest)
    local tActiveQuests = self:GetActiveQuests()
    tActiveQuests[sQuestID] = tQuest
    self:SetActiveQuests( tActiveQuests )

    self:GetPlayer():Notify( "You have started: " .. tQuest.title .. "." )

    return true
end

function CHAR:UpdateQuestTask( sID, sTask, tData )
    if not self:GetActiveQuests()[sID] then return false end

    local tActiveQuests = self:GetActiveQuests()
    local tQuest = tActiveQuests[sID]
    if not tQuest then return false end
    if not tQuest.tasks[sTask] then return false end

    -- @TODO: Holy lord this is ugly. Redo this asap.
    tQuest.tasks[sTask] = tData

    tActiveQuests[sID] = tQuest

    self:SetActiveQuests( tActiveQuests )

    return true
end

function CHAR:CompleteQuest( sID )
    if not self:GetActiveQuests()[sID] then return false end

    local tActiveQuests = self:GetActiveQuests()
    tActiveQuests[sID] = nil
    self:SetActiveQuests( tActiveQuests )

    local tCompletedQuests = self:GetCompletedQuests()
    tCompletedQuests[sID] = true
    self:SetCompletedQuests( tCompletedQuests )

    self:GetPlayer():Notify( "You've successfully completed: " .. PRP.Quest.Get( sID ).title .. "!" )

    return true
end