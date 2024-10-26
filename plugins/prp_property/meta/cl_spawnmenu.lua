local PLUGIN = PLUGIN

PRP.Property = PRP.Property or {}
PRP.Property.SpawnmenuInitialized = PRP.Property.SpawnmenuInitialized or false

-- @TODO: Not working
hook.Add( "CAMI.PlayerUsergroupChanged", "PRP.Property.Spawnmenu.PlayerUsergroupChanged", function( pPlayer )
	Print( "CAMI.PlayerUsergroupChanged" )

	if pPlayer ~= LocalPlayer() then return end
	if not PRP.Property.SpawnmenuInitialized then return end

	RunConsoleCommand( "spawnmenu_reload" )
end )

local function PropCategoryDoClick( dNode, dViewPanel, oCategory )
	dViewPanel:Clear( true )

	local fnContentPanel = spawnmenu.GetContentType( "palomino_prop" )

	if fnContentPanel then
		for _, tModelInfo in pairs( oCategory:GetModels() or {} ) do
			fnContentPanel(
				dViewPanel,
				{
					category = oCategory:GetID(),
					model = tModelInfo.mdl,
					body = tModelInfo.cfg.bodygroups or ""
				}
			)
		end
	end

	dNode.pnlContent:SwitchPanel( dViewPanel )
end

local function AddPropCategory( dParentNode, dContent, oCategory )
	local dViewPanel = vgui.Create( "ContentContainer", dContent )
	dViewPanel:SetVisible( false )
	dViewPanel.IconList:SetReadOnly( true )

	local dCategoryNode = dParentNode:AddNode( oCategory:GetName(), oCategory:GetIcon() )

	dCategoryNode.pnlContent = dContent
	dCategoryNode.ViewPanel = dViewPanel

	dCategoryNode.DoClick = function()
		PropCategoryDoClick( dCategoryNode, dViewPanel, oCategory )
	end

	for _, oSubCategory in pairs( oCategory:GetChildren() or {} ) do
		AddPropCategory( dCategoryNode, dContent, oSubCategory )
	end
end

function PLUGIN:PopulateContent( dContent, dTree, dNode )
	-- if PRP.Property.SpawnmenuInitialized then return end
	-- PRP.Property.SpawnmenuInitialized = true

	spawnmenu.AddContentType( "palomino_prop", function( container, obj )
		local icon = vgui.Create( "SpawnIcon", container )

		-- @TODO: Scale w/ resolution?
		icon:SetWide( 250 )
		icon:SetTall( 250 )

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
		local bFullAccess = CAMI.PlayerHasAccess( LocalPlayer(), "Palomino.Property.BypassPropLimits", nil )

		if ( not bFullAccess ) and ix.config.Get( "doSpawnmenuHiding", true ) then
			-- @TODO: Check for permissions & such.

			dTree:Clear()
		end

		local dPalominoNode = dTree:AddNode( "Palomino" )

		for _, oCategory in pairs( PRP.Prop.Category.GetTree() ) do
			AddPropCategory( dPalominoNode, dContent, oCategory )
		end

		dPalominoNode:ExpandRecurse( true )
	end )
end

-- @TODO: Make it a config thing.
-- if true then return end

-- local bDoHiding = ix.config.Get( "doSpawnmenuHiding", false )
-- if not bDoHiding then return end

function PLUGIN:PreReloadToolsMenu()
	-- Hide the default spawnmenu tabs.

	local dCreationMenu = vgui.GetControlTable( "CreationMenu" )
	dCreationMenu.Populate = function( this )
		local tabs = spawnmenu.GetCreationTabs()

		for k, v in SortedPairsByMemberValue( tabs, "Order" ) do
			local bFullAccess = CAMI.PlayerHasAccess( LocalPlayer(), "Palomino.Property.BypassToolLimitsDangerous", nil )
			if ( ix.config.Get( "doSpawnmenuHiding", true ) ) and ( not bFullAccess ) and k ~= "#spawnmenu.content_tab" then continue end

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
		if not ix.config.Get( "doSpawnmenuHiding", true ) then
			data.AddToMenu = true
		end

		if CAMI.PlayerHasAccess( LocalPlayer(), "Palomino.Property.BypassToolLimitsDangerous", nil ) then
			data.AddToMenu = true
			continue
		end

		if PRP.Property.Tools.Blacklist[ name ] then
			data.AddToMenu = false
			continue
		end

		if CAMI.PlayerHasAccess( LocalPlayer(), "Palomino.Property.BypassToolLimits", nil ) then continue end

		if PRP.Property.Tools.Global[ name ] then continue end

		if PRP.Property.Tools.Situational[ name ] then continue end

		-- @TODO: Is Premium Check
		-- if PRP.Property.Tools.Premium[ name ] then continue end

		data.AddToMenu = false
    end
end

function Schema:PostReloadToolsMenu()
	if not ix.config.Get( "doSpawnmenuHiding", true ) then
		PRP.Property.SpawnmenuInitialized = true
		return
	end

	if CAMI.PlayerHasAccess( LocalPlayer(), "Palomino.Property.BypassToolLimitsDangerous", nil ) then
		PRP.Property.SpawnmenuInitialized = true
		return
	end

	local tToolMenuPanels = g_SpawnMenu.ToolMenu:GetItems()

	-- Loop backwards so we can remove items without breaking the loop.
	for i = #tToolMenuPanels, 1, -1 do
		local dToolPanel = tToolMenuPanels[ i ]

		if dToolPanel.Name == "#spawnmenu.tools_tab" then
			-- Remove empty categories.
			Print( "LIST:" )
			Print( dToolPanel.Panel.List.pnlCanvas:GetChildren() )

			for _, dCategory in pairs( dToolPanel.Panel.List.pnlCanvas:GetChildren() ) do
				if #dCategory:GetChildren() <= 1 then
					dCategory:Remove()
				end
			end
		else
			-- Remove everything but default tools tab.
			g_SpawnMenu.ToolMenu:CloseTab( dToolPanel.Tab )
		end
	end

	PRP.Property.SpawnmenuInitialized = true
end

-- function Schema:AddGamemodeToolMenuCategories()
-- 	spawnmenu.AddToolCategory( "Main", "Constraints",	"#spawnmenu.tools.constraints" )
-- 	spawnmenu.AddToolCategory( "Main", "Construction",	"#spawnmenu.tools.construction" )
-- 	spawnmenu.AddToolCategory( "Main", "Poser",			"#spawnmenu.tools.posing" )
-- 	spawnmenu.AddToolCategory( "Main", "Render",		"#spawnmenu.tools.render" )

-- 	return false
-- end

-- function PLUGIN:PopulatePropMenu()
--     Print( "ran2?")
-- 	return false
-- end

-- Preven tool menu from showing in context menu.
function PLUGIN:ContextMenuShowTool()
	if not ix.config.Get( "doSpawnmenuHiding", true ) then return end

	return false
end

function PLUGIN:PopulateMenuBar( dMenuBar )
	if not ix.config.Get( "doSpawnmenuHiding", true ) then return end

	-- @TODO: This only runs on lua autorefresh for some reason.
	dMenuBar:SetDisabled( true )

	dMenuBar.Paint = function( this, iWidth, iHeight )
		-- @TODO: Paint our own
		surface.SetDrawColor( 255, 255, 255, 32 )
		surface.DrawRect( 0, 0, iWidth, iHeight )

		surface.SetDrawColor( 255, 255, 255, 255 )

		draw.SimpleText( "Palomino.gg", "DermaDefault", 5, iHeight / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	return false
end

-- @TODO: Yucky, and lags client on autorefresh. Maybe only do it once? (See: SpawnMenuCreated)
RunConsoleCommand( "spawnmenu_reload" )