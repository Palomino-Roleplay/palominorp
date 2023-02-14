local PLUGIN = PLUGIN

local dCreationMenu = vgui.GetControlTable( "CreationMenu" )

dCreationMenu.Populate = function( self )
    print("come on!")
    local tabs = spawnmenu.GetCreationTabs()

    for k, v in SortedPairsByMemberValue( tabs, "Order" ) do
        if k ~= "#spawnmenu.content_tab" then continue end

        local pnl = vgui.Create( "Panel" )

		self:AddSheet( k, pnl, v.Icon, nil, nil, v.Tooltip )

		timer.Simple( 0, function()
			local childpnl = v.Function()
			childpnl:SetParent( pnl )
			childpnl:Dock( FILL )
		end )
	end
end

local dToolMenu = vgui.GetControlTable( "ToolMenu" )
dToolMenu.LoadTools = function( self )

	local tools = spawnmenu.GetTools()

	for strName, pTable in pairs( tools ) do
        -- Nice one, garry.
        if pTable.Name ~= "AAAAAAA_Main" then continue end

		self:AddToolPanel( strName, pTable )

	end

end

-- @TODO: Apparently spawnmenu.ClearToolMenus exists. Maybe the above can be done with those functions and more if they exist? PopulateMenuBar, perhaps too.

-- hook.Add( "PopulatePropMenu", "PRP.Property.Spawnmenu.PopulatePropMenu", function( dPanel, dTree, dNode )
--     -- return false
-- end )

function PLUGIN:PopulatePropMenu()
    return false
end

function PLUGIN:PopulateContent()
    return false
end

-- @TODO: Yucky, and lags client on autorefresh. Maybe only do it once? (See: SpawnMenuCreated)
RunConsoleCommand( "spawnmenu_reload" )