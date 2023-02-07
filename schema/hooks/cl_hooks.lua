function Schema:BuildBusinessMenu()
    return false
end

function Schema:PlayerStartVoice( pPlayer )
    if not LocalPlayer():Alive() then return true end
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