local PANEL = {}

local animationTime = 1
local matrixZScale = Vector(1, 1, 0.0001)

DEFINE_BASECLASS("ixSubpanelParent")
local PANEL = {}

AccessorFunc(PANEL, "bCharacterOverview", "CharacterOverview", FORCE_BOOL)

function PANEL:Init()
	if (IsValid(ix.gui.menu)) then
		ix.gui.menu:Remove()
	end

	ix.gui.menu = self

	-- properties
	self.manualChildren = {}
	self.noAnchor = CurTime() + 0.4
	self.anchorMode = true
	self.rotationOffset = Angle(0, 180, 0)
	self.projectedTexturePosition = Vector(0, 0, 6)
	self.projectedTextureRotation = Angle(-45, 60, 0)

	self.currentAlpha = 0
	self.currentBlur = 0

	-- setup
	self:SetPadding(ScreenScale(16), true)
	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)
	self:SetLeftOffset(self:GetWide() * 0.25 + self:GetPadding())

	-- main button panel
	self.buttons = self:Add("Panel")
	self.buttons:SetSize(self:GetWide() * 0.25, self:GetTall() - self:GetPadding() * 2)
	self.buttons:Dock(LEFT)
	self.buttons:SetPaintedManually(true)

	local close = self.buttons:Add("ixMenuButton")
	close:SetText("return")
	close:SizeToContents()
	close:Dock(BOTTOM)
	close.DoClick = function()
		self:Remove()
	end

	-- @todo make a better way to avoid clicks in the padding PLEASE
	self.guard = self:Add("Panel")
	self.guard:SetPos(0, 0)
	self.guard:SetSize(self:GetPadding(), self:GetTall())

	-- tabs
	self.tabs = self.buttons:Add("Panel")
	self.tabs.buttons = {}
	self.tabs:Dock(FILL)
	-- self:PopulateTabs()

	self:MakePopup()
	self:OnOpened()
end

function PANEL:OnOpened()
	self:SetAlpha(0)

	self:CreateAnimation(animationTime, {
		target = {currentAlpha = 255},
		easing = "outQuint",

		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end
	})
end

function PANEL:GetActiveTab()
	return (self:GetActiveSubpanel() or {}).subpanelName
end

function PANEL:TransitionSubpanel(id)
	local lastSubpanel = self:GetActiveSubpanel()

	-- don't transition to the same panel
	if (IsValid(lastSubpanel) and lastSubpanel.subpanelID == id) then
		return
	end

	local subpanel = self:GetSubpanel(id)

	if (IsValid(subpanel)) then
		if (!subpanel.bPopulated) then
			-- we need to set the size of the subpanel if it's a section since it will be 0, 0
			if (subpanel.sectionParent) then
				subpanel:SetSize(self:GetStandardSubpanelSize())
			end

			local info = subpanel.info
			subpanel.Paint = nil

			if (istable(info) and info.Create) then
				info:Create(subpanel)
			elseif (isfunction(info)) then
				info(subpanel)
			end

			hook.Run("MenuSubpanelCreated", subpanel.subpanelName, subpanel)
			subpanel.bPopulated = true
		end

		-- only play whoosh sound only when the menu was already open
		if (IsValid(lastSubpanel)) then
			LocalPlayer():EmitSound("Helix.Whoosh")
		end

		self:SetActiveSubpanel(id)
	end

	subpanel = self:GetActiveSubpanel()

	local info = subpanel.info
	local bHideBackground = istable(info) and (info.bHideBackground != nil and info.bHideBackground or false) or false

	if (bHideBackground) then
		self:HideBackground()
	else
		self:ShowBackground()
	end

	-- call hooks if we've changed subpanel
	if (IsValid(lastSubpanel) and istable(lastSubpanel.info) and lastSubpanel.info.OnDeselected) then
		lastSubpanel.info:OnDeselected(lastSubpanel)
	end

	if (IsValid(subpanel) and istable(subpanel.info) and subpanel.info.OnSelected) then
		subpanel.info:OnSelected(subpanel)
	end

	ix.gui.lastMenuTab = id
end

function PANEL:HideBackground()
	self:CreateAnimation(animationTime, {
		index = 2,
		target = {currentBlur = 0},
		easing = "outQuint"
	})
end

function PANEL:ShowBackground()
	self:CreateAnimation(animationTime, {
		index = 2,
		target = {currentBlur = 1},
		easing = "outQuint"
	})
end

function PANEL:GetStandardSubpanelSize()
	return ScrW() * 0.75 - self:GetPadding() * 2, ScrH() - self:GetPadding() * 2
end

function PANEL:SetupTab(name, info, sectionParent)
	local bTable = istable(info)
	local buttonColor = (bTable and info.buttonColor) or (ix.config.Get("color") or Color(140, 140, 140, 255))
	local bDefault = (bTable and info.bDefault) or false
	local qualifiedName = sectionParent and (sectionParent.name .. "/" .. name) or name

	-- setup subpanels without populating them so we can retain the order
	local subpanel = self:AddSubpanel(qualifiedName, true)
	local id = subpanel.subpanelID
	subpanel.info = info
	subpanel.sectionParent = sectionParent and qualifiedName
	subpanel:SetPaintedManually(true)
	subpanel:SetTitle(nil)

	if (sectionParent) then
		-- hide section subpanels if they haven't been populated to seeing more subpanels than necessary
		-- fly by as you navigate tabs in the menu
		subpanel:SetSize(0, 0)
	else
		subpanel:SetSize(self:GetStandardSubpanelSize())

		-- this is called while the subpanel has not been populated
		subpanel.Paint = function(panel, width, height)
			derma.SkinFunc("PaintPlaceholderPanel", panel, width, height)
		end
	end

	local button

	if (sectionParent) then
		button = sectionParent:AddSection(L(name))
		name = qualifiedName
	else
		button = self.tabs:Add("ixMenuSelectionButton")
		button:SetText(L(name))
		button:SizeToContents()
		button:Dock(TOP)
		button:SetButtonList(self.tabs.buttons)
		button:SetBackgroundColor( self.faction.color )
	end

	button.name = name
	button.id = id
	button.OnSelected = function()
		self:TransitionSubpanel(id)
	end

	if (bTable and info.PopulateTabButton) then
		info:PopulateTabButton(button)
	end

	-- don't allow sections in sections
	if (sectionParent or !bTable or !info.Sections) then
		return bDefault, button, subpanel
	end

	-- create button sections
	for sectionName, sectionInfo in pairs(info.Sections) do
		self:SetupTab(sectionName, sectionInfo, button)
	end

	return bDefault, button, subpanel
end

function PANEL:AddManuallyPaintedChild(panel)
	panel:SetParent(self)
	panel:SetPaintedManually(panel)

	self.manualChildren[#self.manualChildren + 1] = panel
end

function PANEL:OnKeyCodePressed(key)
	self.noAnchor = CurTime() + 0.5

	if (key == KEY_TAB) then
		self:Remove()
	end
end

function PANEL:Think()
	if (IsValid(self.projectedTexture)) then
		local forward = LocalPlayer():GetForward()
		forward.z = 0

		local right = LocalPlayer():GetRight()
		right.z = 0

		self.projectedTexture:SetBrightness(self.overviewFraction * 4)
		self.projectedTexture:SetPos(LocalPlayer():GetPos() + right * 16 - forward * 8 + self.projectedTexturePosition)
		self.projectedTexture:SetAngles(forward:Angle() + self.projectedTextureRotation)
		self.projectedTexture:Update()
	end

	if (self.bClosing) then
		return
	end

	local bTabDown = input.IsKeyDown(KEY_TAB)

	if (bTabDown and (self.noAnchor or CurTime() + 0.4) < CurTime() and self.anchorMode) then
		self.anchorMode = false
		surface.PlaySound("buttons/lightswitch2.wav")
	end

	if ((!self.anchorMode and !bTabDown) or gui.IsGameUIVisible()) then
		self:Remove()
	end
end

function PANEL:Paint(width, height)
	derma.SkinFunc("PaintMenuBackground", self, width, height, self.currentBlur)

	local bShouldScale = self.currentAlpha != 255

	if (bShouldScale) then
		local currentScale = Lerp(self.currentAlpha / 255, 0.9, 1)
		local matrix = Matrix()

		matrix:Scale(matrixZScale * currentScale)
		matrix:Translate(Vector(
			ScrW() * 0.5 - (ScrW() * currentScale * 0.5),
			ScrH() * 0.5 - (ScrH() * currentScale * 0.5),
			1
		))

		cam.PushModelMatrix(matrix)
	end

	BaseClass.Paint(self, width, height)
	self:PaintSubpanels(width, height)
	self.buttons:PaintManual()

	for i = 1, #self.manualChildren do
		self.manualChildren[i]:PaintManual()
	end

	if (IsValid(ix.gui.inv1) and ix.gui.inv1.childPanels) then
		for i = 1, #ix.gui.inv1.childPanels do
			local panel = ix.gui.inv1.childPanels[i]

			if (IsValid(panel)) then
				panel:PaintManual()
			end
		end
	end

	if (bShouldScale) then
		cam.PopModelMatrix()
	end
end

function PANEL:PerformLayout()
	self.guard:SetSize(self.tabs:GetWide() + self:GetPadding() * 2, self:GetTall())
end

function PANEL:Remove()
	self.bClosing = true
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)

	-- remove input from opened child panels since they grab focus
	if (IsValid(ix.gui.inv1) and ix.gui.inv1.childPanels) then
		for i = 1, #ix.gui.inv1.childPanels do
			local panel = ix.gui.inv1.childPanels[i]

			if (IsValid(panel)) then
				panel:SetMouseInputEnabled(false)
				panel:SetKeyboardInputEnabled(false)
			end
		end
	end

	CloseDermaMenus()
	gui.EnableScreenClicker(false)

	self:CreateAnimation(animationTime * 0.5, {
		index = 2,
		target = {currentBlur = 0},
		easing = "outQuint"
	})

	self:CreateAnimation(animationTime * 0.5, {
		target = {currentAlpha = 0},
		easing = "outQuint",

		-- we don't animate the blur because blurring doesn't draw things
		-- with amount < 1 very well, resulting in jarring transition
		Think = function(animation, panel)
			panel:SetAlpha(panel.currentAlpha)
		end,

		OnComplete = function(animation, panel)
			if (IsValid(panel.projectedTexture)) then
				panel.projectedTexture:Remove()
			end

			BaseClass.Remove(panel)
		end
	})
end

function PANEL:SetFaction( iFaction )
    self.faction = ix.faction.indices[ iFaction ]

    self.classes = ix.class.GetByFaction( iFaction )

    -- self:PopulateClasses()
    self:PopulateTabs()
end

function PANEL:PopulateTabs()
    local default
	for k, v in SortedPairsByMemberValue(self.classes, "classLevel", true) do
		local bDefault, button = self:SetupTab(v.name, function( dContainer )
            local dClass = dContainer:Add( "PRP.Job.Menu.Class" )
            dClass:SetFaction( self.faction )
            dClass:SetClass( v )
        end )

		if LocalPlayer():GetCharacter():GetClass() == v.index then
			default = button
		end

        if not default and v.isDefault then
            default = button
        end
	end

	if (IsValid(default)) then
		default:SetSelected(true)
		self:SetActiveSubpanel(default.id, 0)
	end

	self.buttons:MoveToFront()
	self.guard:MoveToBefore(self.buttons)
end

vgui.Register( "PRP.Job.Menu", PANEL, "ixSubpanelParent" )

-- Class panel
PANEL = {}

function PANEL:Init()
	self:SetSize(self:GetParent():GetSize())
end

function PANEL:SetFaction( tFaction )
    self.faction = tFaction
end

function PANEL:SetClass( tClass )
    self.class = tClass

    self:Populate()
end

function PANEL:Populate()
    self.model = self:Add( "DModelPanel" )
    self.model:SetSize( self:GetWide() / 2, self:GetTall() )
    self.model:SetFOV( 25 )
    self.model:Dock( RIGHT )

    -- @TODO: Stop it from being cut off at the bottom
    self.model:SetLookAng( Angle( 0, 200, 0 ) )
    self.model:SetCamPos( Vector( 50, 20, 53 ) )

    -- @TODO: Fix those eyes.
	Print( self.class:GetModel( LocalPlayer() ) )
    self.model:SetModel( self.class:GetModel( LocalPlayer() ) )
	self.model.bInitLayout = true
	self.model.LayoutEntity = function( this, eEntity )
		if self.model.bInitLayout then
			self.model.bInitLayout = false
		end

		Print( self.class.bodygroups )
		eEntity:SetBodyGroups( self.class.bodygroups )
	end

    -- self:GetParent():GetParent():AddManuallyPaintedChild( self.model )

    self.left = self:Add( "EditablePanel" )
    self.left:SetSize( self:GetWide() / 2, self:GetTall() )
    self.left:Dock( LEFT )

    self.classTitle = self.left:Add( "ixLabel" )
    self.classTitle:SetText( self.class.name )
    self.classTitle:SetFont( "ixMenuButtonHugeFont" )
    self.classTitle:SetContentAlignment( 4 )
    self.classTitle:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.classTitle:SetBackgroundColor( ColorAlpha( self.class.color or self.faction.color or ix.Config.Get( "color "), 128 ) )
    self.classTitle:SetPadding( 8 )
    self.classTitle:SetScaleWidth( true )
    self.classTitle:SizeToContents()
    self.classTitle:Dock( TOP )

    self.classDesc = self.left:Add( "ixLabel" )
    self.classDesc:SetText( self.class.description )
    self.classDesc:SetFont( "ixMenuButtonFont" )
    self.classDesc:SetContentAlignment( 4 )
    self.classDesc:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.classDesc:SetPadding( 8 )
    self.classDesc:SetScaleWidth( true )
    self.classDesc:SizeToContents()
    self.classDesc:Dock( TOP )

    -- @TODO: Disable joining if they don't have the requirements
    self.choose = self.left:Add( "ixMenuButton" )
    self.choose:SetText( LocalPlayer():GetCharacter():GetClass() == self.class.index and "Quit" or "Join" )
    self.choose.bIsQuit = LocalPlayer():GetCharacter():GetClass() == self.class.index
    self.choose:SetFont( "ixMenuButtonHugeFont" )
    self.choose:SetContentAlignment( 5 )
    self.choose:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.choose:SetPadding( 8 )
    self.choose:SizeToContents()
    self.choose:Dock( BOTTOM )
    self.choose:SetBackgroundColor( self.class.color or self.faction.color or ix.config.Get( "color" ) )
    self.choose.DoClick = function( this )
        if this.bIsQuit then
            net.Start( "PRP.Job.Quit" )
            net.SendToServer()

            self:GetParent():GetParent():Remove()
            return
        end

        net.Start( "PRP.Job.Select" )
            net.WriteUInt( self.faction.index, 8 )
            net.WriteUInt( self.class.index, 8 )
        net.SendToServer()

        self:GetParent():GetParent():Remove()
    end

    self.salary = self.left:Add( "ixLabel" )
    self.salary:SetText( "Salary: " .. ix.currency.Get( self.class.salary or self.faction.salary or 0 ) )
    self.salary:SetFont( "ixMenuButtonFont" )
    self.salary:SetContentAlignment( 4 )
    self.salary:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.salary:SetPadding( 8 )
    self.salary:SetScaleWidth( true )
    self.salary:SizeToContents()
    self.salary:Dock( TOP )

    self.playerXPLabel = self.left:Add( "ixLabel" )
    self.playerXPLabel:SetText( "--@TODO: Draw Player XP Bar" )
    self.playerXPLabel:SetFont( "ixMenuButtonFont" )
    self.playerXPLabel:SetContentAlignment( 4 )
    self.playerXPLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.playerXPLabel:SetPadding( 8 )
    self.playerXPLabel:SetScaleWidth( true )
    self.playerXPLabel:SizeToContents()
    self.playerXPLabel:Dock( BOTTOM )

    self.playerXPBar = self.left:Add( "ixLabel" )
    self.playerXPBar:SetText( "Player Level:" )
    self.playerXPBar:SetFont( "ixMenuButtonFont" )
    self.playerXPBar:SetContentAlignment( 4 )
    self.playerXPBar:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.playerXPBar:SetPadding( 8 )
    self.playerXPBar:SetScaleWidth( true )
    self.playerXPBar:SizeToContents()
    self.playerXPBar:Dock( BOTTOM )

    self.classXPLabel = self.left:Add( "ixLabel" )
    self.classXPLabel:SetText( "--@TODO: Draw Class XP Bar" )
    self.classXPLabel:SetFont( "ixMenuButtonFont" )
    self.classXPLabel:SetContentAlignment( 4 )
    self.classXPLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.classXPLabel:SetPadding( 8 )
    self.classXPLabel:SetScaleWidth( true )
    self.classXPLabel:SizeToContents()
    self.classXPLabel:Dock( BOTTOM )

    self.classXPBar = self.left:Add( "ixLabel" )
    self.classXPBar:SetText( "Job Level:" )
    self.classXPBar:SetFont( "ixMenuButtonFont" )
    self.classXPBar:SetContentAlignment( 4 )
    self.classXPBar:SetTextColor( Color( 255, 255, 255, 255 ) )
    self.classXPBar:SetPadding( 8 )
    self.classXPBar:SetScaleWidth( true )
    self.classXPBar:SizeToContents()
    self.classXPBar:Dock( BOTTOM )
end

vgui.Register( "PRP.Job.Menu.Class", PANEL, "EditablePanel" )

local dJobPanel = false
concommand.Add( "prp_openjobmenu", function()
    if dJobPanel then
        dJobPanel:Remove()
        dJobPanel = false
    else
        dJobPanel = vgui.Create( "PRP.Job.Menu" )
        dJobPanel:SetFaction( FACTION_POLICE )
    end
end )