local PLUGIN = PLUGIN

PRP.Property = PRP.Property or {}
PRP.Property.SpawnmenuInitialized = PRP.Property.SpawnmenuInitialized or false

function PLUGIN:PopulateContent( dContent, dTree, dNode )
	-- if PRP.Property.SpawnmenuInitialized then return end
	-- PRP.Property.SpawnmenuInitialized = true

	spawnmenu.AddContentType( "palomino_prop", function( container, obj )
		local icon = vgui.Create( "SpawnIcon", container )

		icon:SetWide( 256 )
		icon:SetTall( 256 )

		icon:InvalidateLayout( true )

		icon:SetModel( obj.model, obj.skin or 0, obj.body )

		icon:SetTooltip( string.Replace( string.GetFileFromFilename( obj.model ), ".mdl", "" ) )

		icon.DoClick = function( s )
			surface.PlaySound( "prp/ui/click.wav" )

			net.Start( "PRP.Prop.Spawn" )
				net.WriteString( obj.category )
				net.WriteString( obj.model )
			net.SendToServer()
			-- RunConsoleCommand( "gm_spawn", s:GetModelName(), s:GetSkinID() or 0, s:GetBodyGroup() or "" )
		end

		icon:InvalidateLayout( true )

		if ( IsValid( container ) ) then
			container:Add( icon )
		end
	end )

	-- This is literally how Rubat does it.
	timer.Simple( 1, function()
		if ix.config.Get("doSpawnmenuHiding", false) then
			dTree:Clear()
		end

		local dPalominoNode = dTree:AddNode( "Palomino" )

		for _, tPropCategory in pairs( PLUGIN.config.props ) do
			local dViewPanel = vgui.Create( "ContentContainer", dContent )
			dViewPanel:SetVisible( false )
			dViewPanel.IconList:SetReadOnly( true )

			local dCategoryNode = dPalominoNode:AddNode( tPropCategory.name, tPropCategory.icon or "icon16/brick.png" )
			dCategoryNode.pnlContent = dContent
			dCategoryNode.ViewPanel = dViewPanel
			dCategoryNode:SetExpanded( true )

			for _, tPropSubcategory in pairs( tPropCategory.subcategories ) do
				local dSubcategoryNode = dCategoryNode:AddNode( tPropSubcategory.name, tPropSubcategory.icon or "icon16/brick.png" )

				dSubcategoryNode.DoClick = function()
					dViewPanel:Clear( true )

					local cp = spawnmenu.GetContentType( "palomino_prop" )

					if cp then
						for sModelPath, tModelSettings in pairs( tPropSubcategory.models ) do
							cp( dViewPanel, { category = tPropSubcategory.categoryID, model = sModelPath, body = tModelSettings.bodygroups or "" } )
						end
					end

					dCategoryNode.pnlContent:SwitchPanel( dViewPanel )
				end

				dSubcategoryNode.pnlContent = dContent
				dSubcategoryNode.ViewPanel = dViewPanel
			end
		end

		dPalominoNode:ExpandRecurse( true )
	end )
end

-- @TODO: Make it a config thing.
if true then return end

-- local bDoHiding = ix.config.Get( "doSpawnmenuHiding", false )
-- if not bDoHiding then return end

-- The tools that we are going to hide from the menu.
local tToolsToShow = {
    light = true,
    remover = true,
	wheel = true,
	button = true,
	material = true,
	rope = true,
	-- @TODO: Below doesn't work.
	colour = true,
}

function PLUGIN:PreReloadToolsMenu()
	-- Hide the default spawnmenu tabs.
	local dCreationMenu = vgui.GetControlTable( "CreationMenu" )
	dCreationMenu.Populate = function( this )
		print("come on!")
		local tabs = spawnmenu.GetCreationTabs()

		for k, v in SortedPairsByMemberValue( tabs, "Order" ) do
			if k ~= "#spawnmenu.content_tab" then continue end

			local pnl = vgui.Create( "Panel" )

			this:AddSheet( k, pnl, v.Icon, nil, nil, v.Tooltip )

			timer.Simple( 0, function()
				local childpnl = v.Function()
				childpnl:SetParent( pnl )
				childpnl:Dock( FILL )
			end )
		end
	end


	-- Show only the tools we want to show.
    for name, data in pairs( weapons.GetStored( "gmod_tool" ).Tool ) do
        if not tToolsToShow[ name ] then
            data.AddToMenu = false
        end
    end
end

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

hook.Add( "PopulatePropMenu", "PRP.Property.Spawnmenu.PopulatePropMenu", function( dPanel, dTree, dNode )
    return false
end )

function PLUGIN:PopulatePropMenu()
    return false
end

-- function PLUGIN:PopulateMenuBar( dMenuBar )
	-- dMenuBar:GetParent():Hide()

-- 	dMenuBar:SetPaintBackground( false )
-- 	dMenuBar:SetDisabled( true )
-- 	dMenuBar:Hide()

-- 	return false
-- end

-- @TODO: Yucky, and lags client on autorefresh. Maybe only do it once? (See: SpawnMenuCreated)
RunConsoleCommand( "spawnmenu_reload" )