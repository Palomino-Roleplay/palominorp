PRP = PRP or {}
PRP.UI = PRP.UI or {}

local PANEL = {}

function PANEL:Init()
    -- self.m_pnlCanvas = vgui.Create( "Panel", self )
    self._tabs = {}

    self.m_pnlHeader = vgui.Create( "DIconLayout", self )
    self.m_pnlHeader:SetSpaceX( 0 )
    self.m_pnlHeader:SetSpaceY( 0 )
    self.m_pnlHeader:Dock( TOP )
    self.m_pnlHeader:SetTall( 100 * PRP.UI.ScaleFactor )
    self.m_pnlHeader:SetWide( ScrW() )
    self.m_pnlHeader:SetLayoutDir( TOP )

    self:SetSize( ScrW(), ScrH() )
end

function PANEL:AddTab( sName )
    local dTab = self.m_pnlHeader:Add( "PRP.TabMenu.Tab" )
    dTab:SetName( sName )
    dTab:SetParent( self )
    dTab:SetVisible( true )
    table.insert( self._tabs, dTab )

    -- Calculate the total width of all tabs
    local totalWidth = 0
    for _, tab in ipairs(self._tabs) do
        totalWidth = totalWidth + tab:GetWide()
    end

    -- Correctly position tabs
    local currentPos = (ScrW() - totalWidth) / 2 -- Starting position
    for i, tab in ipairs(self._tabs) do
        tab:SetPos(currentPos, 50 * PRP.UI.ScaleFactor)
        currentPos = currentPos + tab:GetWide()
    end

    return dTab
end


function PANEL:Paint(w, h)
    -- draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0, 1 ) )
    return
end

function PANEL:OnRemove()
end

vgui.Register( "PRP.TabMenu", PANEL, "DPanel" )