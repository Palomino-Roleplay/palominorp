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

    self._bTabSwitchLock = false

    self._iCurrentTab = self._iCurrentTab or 1
    self._iTabSwitchTime = 0

    self:SetSize( ScrW(), ScrH() )
end

function PANEL:AddTab( sName )
    local dTab = self.m_pnlHeader:Add( "PRP.TabMenu.Tab" )
    dTab:SetName( sName )
    dTab:SetParent( self )
    dTab:SetVisible( true )
    local iID = table.insert( self._tabs, dTab )
    dTab._iID = iID - 1

    -- Correctly position tabs
    self.iStartingPos = ( ScrW() - ( 250 * PRP.UI.ScaleFactor * #self._tabs ) ) / 2
    local currentPos = self.iStartingPos -- Starting position
    for i, tab in ipairs(self._tabs) do
        tab:SetPos( currentPos, 50 * PRP.UI.ScaleFactor )
        currentPos = currentPos + tab:GetWide()
    end

    self._iCursorPosEased = self.iStartingPos

    self:UpdateActiveTab()

    return dTab
end

function PANEL:SetActiveTab( iID )
    self._iCurrentTab = iID
    self._iTabSwitchTime = CurTime()
    self:UpdateActiveTab()

    surface.PlaySound( "palomino/ui/whoosh.wav" )
end

function PANEL:UpdateActiveTab()
    for i, tab in ipairs(self._tabs) do
        tab:SetActive( i - 1 == self._iCurrentTab )
    end
end

function PANEL:Think()
    -- @TODO: AIDS
    if not self._bTabSwitchLock and input.IsKeyDown( KEY_Q ) then
        self._bTabSwitchLock = true

        self:SetActiveTab( ( self._iCurrentTab - 1 ) % #self._tabs )
    elseif not self._bTabSwitchLock and input.IsKeyDown( KEY_E ) then
        self._bTabSwitchLock = true

        self:SetActiveTab( ( self._iCurrentTab + 1 ) % #self._tabs )
    elseif not input.IsKeyDown( KEY_Q ) and not input.IsKeyDown( KEY_E ) then
        self._bTabSwitchLock = false
    end
end


local oGradientMaterial = Material( "gui/gradient_up" )
function PANEL:Paint(w, h)
    local iTabWidth = 250 * PRP.UI.ScaleFactor
    local iTabHeight = 50 * PRP.UI.ScaleFactor
    local iLowerBarHeight = (2 * PRP.UI.ScaleFactor)

    local iCursorPos = self.iStartingPos

    self._iCursorPosEased = Lerp( FrameTime() * 20, self._iCursorPosEased, iCursorPos + ( self._iCurrentTab * iTabWidth ) )

    -- draw.RoundedBox( 0, iCursorPos, 0, iTabWidth, iTabHeight, Color( 255, 0, 0, 1 ) )

    draw.SimpleText( self._iCurrentTab, "Trebuchet24", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    
    surface.SetDrawColor( 39, 150, 110, 128 )
    surface.SetMaterial( oGradientMaterial )
    surface.DrawTexturedRect( self._iCursorPosEased, iTabHeight, iTabWidth, iTabHeight )
    
    draw.RoundedBox( 0, self._iCursorPosEased, iTabHeight + iTabHeight - iLowerBarHeight, iTabWidth, iLowerBarHeight, Color( 0, 209, 132) )
    
    return
end

function PANEL:OnRemove()
end

vgui.Register( "PRP.TabMenu", PANEL, "DPanel" )