PRP.UI = PRP.UI or {}

local oMaterial = Material( "gui/gradient_up" )

local PANEL = {}

surface.CreateFont( "PRP_TabMenu_Tab", {
    font = "Inter Bold",
    size = 24 * PRP.UI.ScaleFactor,
    weight = 24,
    antialias = true,
    shadow = false
} )

function PANEL:Init()
    -- self.m_pnlCanvas = vgui.Create( "Panel", self )
    self:SetWide( 240 * PRP.UI.ScaleFactor )
    self:SetTall( 50 * PRP.UI.ScaleFactor )

    self:SetText( "" )

    self.m_bActive = false
end

function PANEL:SetName( sName )
    self.m_strName = sName
end

function PANEL:SetActive( bActive )
    self.m_bActive = bActive
end

function PANEL:Paint(w, h)
    local iLowerBarHeight = (2 * PRP.UI.ScaleFactor)
    draw.RoundedBox( 0, 0, h - iLowerBarHeight, w, iLowerBarHeight, Color( 255, 255, 255, 40 ) )
    -- surface.SetDrawColor( 39, 150, 110, 128 )
    -- surface.SetMaterial( oMaterial )
    -- surface.DrawTexturedRect( 0, 0, w, h - iLowerBarHeight )

    draw.SimpleText( self.m_strName, "PRP_TabMenu_Tab", w / 2, h / 2, Color( 255, 255, 255, self.m_bActive and 255 or 40 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function PANEL:OnRemove()
end

function PANEL:DoClick()
    self:GetParent():SetActiveTab( self._iID )
end

vgui.Register( "PRP.TabMenu.Tab", PANEL, "DButton" )