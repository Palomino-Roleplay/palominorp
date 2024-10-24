PRP.UI = PRP.UI or {}

local PANEL = {}

-- @TODO: Gross. Replace with our own.
local MAT_GRADIENT = Material( "gui/gradient" )

surface.CreateFont( "PRP.Select.Button", {
    font = "Inter",
    size = 24,
    weight = 700,
    antialias = true
})

AccessorFunc( PANEL, "m_sLabel", "Label" )

function PANEL:Init()
    self:SetSize( 400, 65 )
    self:SetText( "" )

    self.m_bHoverSoundPlayed = false
end

function PANEL:OpenSubMenu( fnCallback )
    if self:HasSubMenu() then
        self:CloseSubMenu()
        return
    end

    self.m_pSubMenu = vgui.Create( "PRP.Select", self:GetParent():GetParent() )
    Print( "POS:")
    Print( self:GetParent().x + self:GetParent():GetWide() + 100 )
    Print( self:GetParent().y )
    self.m_pSubMenu:SetPos( self:GetParent().x + self:GetParent():GetWide() + 100, self:GetParent().y )

    fnCallback( self.m_pSubMenu )
end

function PANEL:CloseSubMenu()
    if self.m_pSubMenu then
        self.m_pSubMenu:Remove()
        self.m_pSubMenu = nil
    end
end

function PANEL:HasSubMenu()
    return self.m_pSubMenu != nil
end

function PANEL:Paint( iWidth, iHeight )

    if self:GetDisabled() then
        surface.SetDrawColor( 255, 255, 255, 76 )
        surface.SetTextColor( 255, 255, 255, 76 )
    elseif self:HasSubMenu() then
        surface.SetDrawColor( ColorAlpha( PUI.GREEN, 32 ) )
        surface.SetMaterial( MAT_GRADIENT )
        surface.DrawTexturedRect( 2, 0, iWidth - 2, iHeight )

        surface.SetTextColor( 255, 255, 255, 255 )
        surface.SetDrawColor( PUI.GREEN:Unpack() )
    elseif self:IsHovered() then
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetTextColor( 255, 255, 255, 255 )
    else
        surface.SetDrawColor( 255, 255, 255, 128 )
        surface.SetTextColor( 255, 255, 255, 128 )
    end

    surface.DrawRect( 0, 0, 2, iHeight )
    surface.SetFont( "PRP.Select.Button" )
    surface.SetTextPos( 20, iHeight / 2 - 10 )

    surface.DrawText( self:GetLabel() )
end

function PANEL:Think()
    if self:IsHovered() and not self.m_bHoverSoundPlayed then
        surface.PlaySound( "prp/ui/hover.wav" )
        self.m_bHoverSoundPlayed = true
    elseif not self:IsHovered() then
        self.m_bHoverSoundPlayed = false
    end
end

vgui.Register( "PRP.Select.Button", PANEL, "DButton" )

PANEL = {}

function PANEL:Init()
    self.m_tButtons = {}

    self:SetSize( 400, 65 )
end

function PANEL:AddButton( sLabel, fnCallback, bDisabled )
    local pButton = vgui.Create( "PRP.Select.Button", self )
    pButton:SetLabel( sLabel )
    pButton:SetDisabled( bDisabled or false )
    pButton:Dock( BOTTOM )
    pButton:DockMargin( 0, 0, 0, 0 )
    pButton.DoClick = function()
        -- @TODO: This should be under the button itself probably.
        surface.PlaySound( "prp/ui/click.wav" )

        fnCallback( pButton )
    end

    table.insert( self.m_tButtons, pButton )

    self:SetTall( #self.m_tButtons * 65 )
end

function PANEL:Paint()
    return
end

vgui.Register( "PRP.Select", PANEL, "DPanel" )