function Schema:BuildBusinessMenu()
    return false
end

-- Can't do Schema:PopulateHelpMenu() because it's run before tTabs["plugins"] is added
hook.Add( "PopulateHelpMenu", "Test.PopulateHelpMenu", function( tTabs )
    tTabs["plugins"] = nil
end )