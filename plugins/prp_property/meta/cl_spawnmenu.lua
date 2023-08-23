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

-- The tools that we are going to hide from the menu.
local toolsToShow = {
    light = true,
    remover = true,
	wheel = true,
	button = true,
	material = true,
	color = true,
	rope = true,
}

hook.Add( "PreReloadToolsMenu", "HideTools", function()
    -- Tool contains information about all registered tools.
    for name, data in pairs( weapons.GetStored( "gmod_tool" ).Tool ) do
        if not toolsToShow[ name ] then
            data.AddToMenu = false
        end
    end
end )

function Schema:PostReloadToolsMenu()
	local tToolMenuPanels = g_SpawnMenu.ToolMenu:GetItems()

	-- Loop backwards so we can remove items without breaking the loop.
	for i = #tToolMenuPanels, 1, -1 do
		local dToolPanel = tToolMenuPanels[ i ]

		if dToolPanel.Name ~= "#spawnmenu.tools_tab" then
			g_SpawnMenu.ToolMenu:CloseTab( dToolPanel.Tab )
		end
	end
end

function Schema:AddGamemodeToolMenuCategories()
	spawnmenu.AddToolCategory( "Main", "Constraints",	"#spawnmenu.tools.constraints" )
	spawnmenu.AddToolCategory( "Main", "Construction",	"#spawnmenu.tools.construction" )
	-- spawnmenu.AddToolCategory( "Main", "Poser",			"#spawnmenu.tools.posing" )
	spawnmenu.AddToolCategory( "Main", "Render",		"#spawnmenu.tools.render" )

	return false
end

-- local dToolMenu = vgui.GetControlTable( "ToolMenu" )
-- dToolMenu.LoadTools = function( self )

-- 	local tools = spawnmenu.GetTools()

-- 	for strName, pTable in pairs( tools ) do
--         -- Nice one, garry.
--         -- if not LocalPlayer():IsAdmin() and pTable.Name ~= "AAAAAAA_Main" then continue end

-- 		self:AddToolPanel( strName, pTable )

-- 	end

-- end

-- @TODO: Apparently spawnmenu.ClearToolMenus exists. Maybe the above can be done with those functions and more if they exist? PopulateMenuBar, perhaps too.

hook.Add( "PopulatePropMenu", "PRP.Property.Spawnmenu.PopulatePropMenu", function( dPanel, dTree, dNode )
    return false
end )

function PLUGIN:PopulatePropMenu()
    return false
end

function PLUGIN:PopulateMenuBar( dMenuBar )
	-- dMenuBar:GetParent():Hide()

	dMenuBar:SetPaintBackground( false )
	dMenuBar:SetDisabled( true )
	dMenuBar:Hide()

	return false
end

function PLUGIN:PopulateContent( dContent, dTree, dNode )
	-- Print( dTree:Root():GetPathID() )
	-- local browseSounds = tree:AddNode( "#spawnmenu.category.browsesounds", "icon16/sound.png" )

	-- dTree:Root():AddNode( "Hi, my name is" )

	-- This is literally how Rubat does it.
	timer.Simple( 1, function()
		Print( "Populate Content" )

		Print( "---" )

		-- dNode:Remove()
		Print( dTree:Clear() )

		Print( "---" )

		Print( "/Populate Content" )

		local dPalominoNode = dTree:AddNode( "Palomino" )

		local dDefensesNode = dPalominoNode:AddNode( "Defensive Props", "icon16/bomb.png" )
		local dDecorNode = dPalominoNode:AddNode( "Decorative Props", "icon16/picture.png" )
		local dRegularProps = dPalominoNode:AddNode( "Regular Props", "icon16/brick.png" )

		dPalominoNode:ExpandRecurse( true )
	end )

    -- local dViewPanel = vgui.Create( "ContentContainer", dContent )
	-- dViewPanel:SetVisible( false )
	-- dViewPanel.IconList:SetReadOnly( true )

	-- local dPalominoNode = dNode:AddNode( "Palomino", "icon16/folder_database.png" )
	-- dPalominoNode.pnlContent = dContent
	-- dPalominoNode.ViewPanel = dViewPanel
    -- dPalominoNode:SetExpanded( true )

	-- local dRoleplayProps = dPalominoNode:AddNode( "Furniture", "icon16/house.png" )
	-- dRoleplayProps.DoClick = function()
    --     -- @TODO: Needs to be precached
	-- 	dViewPanel:Clear( true )

	-- 	local cp = spawnmenu.GetContentType( "model" )
	-- 	if cp then
	-- 		for k, v in ipairs( file.Find( "models/*.mdl", "GAME" ) ) do
	-- 			cp( dViewPanel, { model = "models/" .. v } )
	-- 		end
	-- 	end

	-- 	dPalominoNode.pnlContent:SwitchPanel( dViewPanel )
	-- end

    -- local dDecorProps = dPalominoNode:AddNode( "Decor", "icon16/picture.png" )
	-- dDecorProps.DoClick = function()
    --     -- @TODO: Needs to be precached
	-- 	dViewPanel:Clear( true )

	-- 	local cp = spawnmenu.GetContentType( "model" )
	-- 	if cp then
	-- 		for k, v in ipairs( file.Find( "models/*.mdl", "GAME" ) ) do
	-- 			cp( dViewPanel, { model = "models/" .. v } )
	-- 		end
	-- 	end

	-- 	dPalominoNode.pnlContent:SwitchPanel( dViewPanel )
	-- end

    -- if not LocalPlayer():IsAdmin() then
    --     return false
    -- end
end

function PLUGIN:SpawnMenuCreated()

end

spawnmenu.AddContentType( "palomino_prop", function( container, obj )
	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "palomino_prop" )
	icon:SetSpawnName( "Palomino" )
	icon:SetName( "Palomino Prop" )
	icon:SetMaterial( "icon16/sound.png" )

	icon.DoClick = function()

	end

	icon.OpenMenu = function( icon )

	end

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon

end )

-- @TODO: Yucky, and lags client on autorefresh. Maybe only do it once? (See: SpawnMenuCreated)
RunConsoleCommand( "spawnmenu_reload" )