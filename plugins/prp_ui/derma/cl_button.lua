PRP.UI = PRP.UI or {}

surface.CreateFont( "PRP.UI.Button", {
    font = "Inter Bold",
    size = 20 * PRP.UI.ScaleFactor,
    -- weight = 600,
    antialias = true
} )

surface.CreateFont( "PRP.UI.Key", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    weight = 800,
    antialias = true
} )

local PANEL = {}

AccessorFunc( PANEL, "m_iPadding", "Padding" )

function PANEL:Init()
    -- self.m_pnlCanvas = vgui.Create( "Panel", self )
    -- self:SetWide( 240 * PRP.UI.ScaleFactor )
    -- self:SetTall( 50 * PRP.UI.ScaleFactor )

    self:SetText( "" )

    self.m_iMultiplier = 0
    self.m_sLabelCache = ""
    self.m_iPadding = 20 * PRP.UI.ScaleFactor

    -- self.m_bActive = false
end

function PANEL:DoClick()
    -- self:GetParent():SetActiveTab( self._iID )
    self:Remove()
end

local oMaterial = Material( "gui/gradient_down" )
function PANEL:Paint( w, h )
    surface.SetDrawColor( 137, 191, 255, 255 )
    surface.DrawOutlinedRect( 0, 0, w, h, 1 )

    surface.SetDrawColor( 137, 191, 255, 8 + ( 24 * self.m_iMultiplier ) )
    surface.DrawRect( 0, 0, w, h )

    surface.SetMaterial( oMaterial )
    surface.SetDrawColor( 137, 191, 255, 16 - ( 16 * self.m_iMultiplier ) )
    surface.DrawTexturedRect( 0, 0, w, h )

    draw.SimpleText( string.upper( self:GetLabel() ), "PRP.UI.Button", w / 2, h / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    self.m_iState = 0
end

function PANEL:SetLabel( sLabel )
    self.m_sLabel = sLabel

    surface.SetFont( "PRP.UI.Button" )
    local w, h = surface.GetTextSize( self.m_sLabel )
    self:SetSize( w + 3 * self:GetPadding(), h + self:GetPadding() )
end

function PANEL:GetLabel()
    return self.m_sLabel
end

function PANEL:Think()
    -- self:SetCursor( "hourglass" )

    if self:IsHovered() then
        self.m_iMultiplier = Lerp( FrameTime() * 10, self.m_iMultiplier, 0.5 )
    -- elseif self:OnMousePressed() then
    --     self.m_iMultiplier = Lerp( FrameTime() * 10, self.m_iMultiplier, 1 )
    else
        self.m_iMultiplier = Lerp( FrameTime() * 10, self.m_iMultiplier, 0 )
    end
end

vgui.Register( "PRP.Button", PANEL, "DButton" )

-- Test DFrame

PANEL = {}

function PANEL:Init()
    self:SetSize( 400, 400 )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:ShowCloseButton( true )
end

vgui.Register( "PRP.TestFrame", PANEL, "DFrame" )

concommand.Add( "prp_testbutton", function()
    local dTest = vgui.Create( "PRP.TestFrame" )

    local dButton = vgui.Create( "PRP.Button", dTest )
    dButton:SetPos( 50, 50 )
    dButton:SetLabel( "I UNDERSTAND" )
end )

-- Keyboard Button Display

PANEL = {}

function PANEL:Init()
    self:SetSize( 48, 48 )
    -- self:Center()
    -- self:MakePopup()
    -- self:SetTitle( "" )
    -- self:ShowCloseButton( true )
end

function PANEL:SetKey( iKey )
    self.m_iKey = iKey
end

function PANEL:Paint( iW, iH )
    -- -- PUI.StartOverlay()
    --     surface.SetDrawColor( 217, 217, 217, 255 * 0.1 * 0.25 )
    --     surface.DrawRect( 0, 0, iW, iH )
    -- -- PUI.EndOverlay()

    -- surface.SetDrawColor( 255, 255, 255, 255 * 0.2 * 0.25 )
    -- surface.DrawOutlinedRect( 0, 0, iW, iH, 2 )

    -- surface.SetTextColor( 255, 255, 255, 255 * 0.4 * 0.25 )
    -- surface.SetFont( "PRP.UI.Key" )

    local sKeyName = string.lower( input.GetKeyName( self.m_iKey or 0 ) or "" )
    surface.SetMaterial( Material( "prp/ui/temp/key_" .. sKeyName .. ".png" ) )
    surface.SetDrawColor( 255, 255, 255, 255 * 0.35 )
    surface.DrawTexturedRect( 0, 0, iW, iH )
    -- local w, h = surface.GetTextSize( sKeyName )
    -- surface.SetTextPos( iW / 2 - w / 2, iH / 2 - h / 2 )
    -- surface.DrawText( sKeyName )
end

vgui.Register( "PRP.KeyboardButton", PANEL, "DPanel" )