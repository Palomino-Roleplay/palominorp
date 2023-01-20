function Schema:CanPlayerUseBusiness()
    return false
end

function Schema:CanPlayerJoinClass()
    return false
end

-- Disable some default plugins
local tDisabledPlugins = {
    ["recognition"] = true
}

function Schema:ShouldLoadPlugin(sPlugin)
    if (tDisabledPlugins[sPlugin]) then return false end
end