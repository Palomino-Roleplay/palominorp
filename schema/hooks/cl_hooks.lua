function Schema:BuildBusinessMenu()
    return false
end

function Schema:PlayerStartVoice( pPlayer )
    -- if pPlayer == LocalPlayer() then return end
    -- print("wtff!!!")
    

    -- if pPlayer == LocalPlayer() then
    --     print("wtf???")
    --     if not pPlayer._bInRadio then return true end
    -- end

    -- if LocalPlayer():OnSameChannel( pPlayer ) then
    --     print( "On same channel" )
    --     -- pPlayer._bInRadio = true
    --     -- return true
    -- else
    --     print( "Not on same channel" )
    --     -- pPlayer._bInRadio = false
    --     -- return false
    -- end

    if not LocalPlayer():Alive() then return true end
    if LocalPlayer():OnSameChannel( pPlayer ) and pPlayer:GetNWBool( "bInRadio", false ) then
        surface.PlaySound( "npc/metropolice/vo/off4.wav" )
        return
    end
    -- if pPlayer == LocalPlayer() then return true end

    -- return false
end

-- Can't do Schema:PopulateHelpMenu() because it's run before tTabs["plugins"] is added
hook.Add( "PopulateHelpMenu", "PRP.Hooks.PopulateHelpMenu", function( tTabs )
    tTabs["helix"] = function(container)
        container:Add("ixCredits")
    end
    tTabs["plugins"] = nil
end )
hook.Remove( "PopulateHelpMenu", "ixCredits" )

function Schema:CanCreateCharacterInfo( tSuppress )
    tSuppress.attributes = true
    tSuppress.description = true
end

-- Prevent accidental shooting while clicking in C menu
function Schema:PreventScreenClicks()
    return true
end