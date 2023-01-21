function Schema:BuildBusinessMenu()
    return false
end

-- Can't do Schema:PopulateHelpMenu() because it's run before tTabs["plugins"] is added
hook.Add( "PopulateHelpMenu", "Test.PopulateHelpMenu", function( tTabs )
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