local PANEL = {}

function PANEL:Init()
    self:SetSize( 900, 700 )
    self:Center()
    self:MakePopup()

    self.classList = vgui.Create( "DScrollPanel", self )
    self.classList:Dock( LEFT )
    self.classList:SetWide( 300 )
end

function PANEL:SetFaction( iFaction )
    self.faction = ix.faction.indices[ iFaction ]

    self.classes = ix.class.GetByFaction( iFaction )
    Print("test?")
    Print( self.classes )

    self:PopulateClasses()
end

function PANEL:PopulateClasses()
    self.classList:Clear()

    self.classButtons = {}
    for k, v in pairs( self.classes ) do
        self.classButtons[k] = vgui.Create( "ixMenuSelectionButton", self.classList )
        self.classButtons[k]:SetText( v.name )
        self.classButtons[k]:SizeToContents()
        self.classButtons[k]:Dock( TOP )
        self.classButtons[k]:SetButtonList(self.classButtons)
        self.classButtons[k]:SetBackgroundColor( self.faction.color )

        -- self.classList:AddItem( class )
    end
end

vgui.Register( "PRP.Job.Menu", PANEL, "DFrame" )

local dJobPanel = false
concommand.Add( "prp_openjobmenu", function()
    if dJobPanel then
        dJobPanel:Remove()
        dJobPanel = false
    else
        dJobPanel = vgui.Create( "PRP.Job.Menu" )
        dJobPanel:SetFaction( LocalPlayer():Team() )
    end
end )