PRP = PRP or {}
PRP.UI = PRP.UI or {}

local PANEL = {}

function PANEL:Init()
    -- self.m_pnlCanvas = vgui.Create( "Panel", self )
    self._tabs = {}

    self.m_pnlHeaderCanvas = vgui.Create( "DIconLayout", self )
    self.m_pnlHeaderCanvas:SetSpaceX( 50 )
    self.m_pnlHeaderCanvas:SetSpaceY( 0 )
    self.m_pnlHeaderCanvas:Dock( TOP )
    self.m_pnlHeaderCanvas:SetTall( 100 * PRP.UI.ScaleFactor )
    self.m_pnlHeaderCanvas:SetWide( ScrW() )
    self.m_pnlHeaderCanvas:SetLayoutDir( TOP )

    self.m_pnlButtonQ = self:Add( "PRP.KeyboardButton" )
    self.m_pnlButtonQ:SetKey( KEY_Q )

    self.m_pnlButtonE = self:Add( "PRP.KeyboardButton" )
    self.m_pnlButtonE:SetKey( KEY_E )

    self.m_pnlHeader = vgui.Create( "DIconLayout", self.m_pnlHeaderCanvas )
    self.m_pnlHeader:SetSpaceX( 0 )
    self.m_pnlHeader:SetSpaceY( 0 )
    self.m_pnlHeader:Dock( TOP )
    self.m_pnlHeader:SetTall( 100 * PRP.UI.ScaleFactor )
    self.m_pnlHeader:SetWide( ScrW() )
    self.m_pnlHeader:SetLayoutDir( TOP )

    self._bTabSwitchLock = false

    self._iCurrentTab = self._iCurrentTab or 2
    self._iTabSwitchTime = 0

    self._iPanelPosEased = 0

    self:SetSize( ScrW(), ScrH() )

    self.m_pnlContent = vgui.Create( "DIconLayout", self )
    self.m_pnlContent:SetPos( 0, 100 * PRP.UI.ScaleFactor )
    self.m_pnlContent:SetSize( ScrW(), ScrH() - ( 100 * PRP.UI.ScaleFactor ) )
    self.m_pnlContent:SetSpaceX( 0 )
    self.m_pnlContent:SetSpaceY( 0 )
    -- self.m_pnlContent:SetLayoutDir( TOP )
    self.m_pnlContent.Paint = function( _, intW, intH )
        -- draw.RoundedBox( 0, 0, 0, intW, intH, Color( 0, 255, 0, 50 ) )
    end
end

function PANEL:AddTab( sName )
    local dTab = self.m_pnlHeader:Add( "PRP.TabMenu.Tab" )
    dTab:SetName( sName )
    dTab:SetParent( self )
    dTab:SetVisible( true )
    local iID = table.insert( self._tabs, dTab )
    dTab._iID = iID - 1

    -- Correctly position tabs
    self.iStartingPos = ( ScrW() - ( 240 * PRP.UI.ScaleFactor * #self._tabs ) ) / 2
    local currentPos = self.iStartingPos -- Starting position
    for i, tab in ipairs(self._tabs) do
        tab:SetPos( currentPos, 50 * PRP.UI.ScaleFactor )
        currentPos = currentPos + tab:GetWide()
    end

    self.m_pnlContent:SetWide( ScrW() * #self._tabs )

    dTab.m_pnlContent = self.m_pnlContent:Add( "Panel" )
    dTab.m_pnlContent:SetSize( ScrW(), self.m_pnlContent:GetTall() )
    dTab.m_pnlContent.Paint = function()
        -- draw.SimpleText( "Tab " .. iID, "Trebuchet24", 0, 24, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
        -- draw.SimpleText( dTab.m_strName, "Trebuchet24", 0, 48, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    end

    self._iCursorPosEased = self.iStartingPos
    -- Start on 3rd tab
    -- @TODO: AIDS
    self._iCursorPosEased = self._iCursorPosEased + ( 2 * 240 * PRP.UI.ScaleFactor )
    self._iPanelPosEased = ScrW() * 2

    self.m_pnlButtonQ:SetPos( self.iStartingPos - ( 100 * PRP.UI.ScaleFactor ), 48 )
    self.m_pnlButtonE:SetPos( self.iStartingPos + ( 240 * PRP.UI.ScaleFactor * #self._tabs ) + ( 50 * PRP.UI.ScaleFactor ), 48 )


    self:UpdateActiveTab()

    return dTab, dTab.m_pnlContent
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
    local iTabWidth = 240 * PRP.UI.ScaleFactor
    local iTabHeight = 50 * PRP.UI.ScaleFactor
    local iLowerBarHeight = (2 * PRP.UI.ScaleFactor)

    local iCursorPos = self.iStartingPos
    local iPanelPos = 0

    self._iCursorPosEased = Lerp( FrameTime() * 30, self._iCursorPosEased, iCursorPos + ( self._iCurrentTab * iTabWidth ) )
    self._iPanelPosEased = Lerp( FrameTime() * 30, self._iPanelPosEased, iPanelPos + ( self._iCurrentTab * ScrW() ) )

    self.m_pnlContent:SetPos( -self._iPanelPosEased, 100 * PRP.UI.ScaleFactor )

    -- draw.RoundedBox( 0, iCursorPos, 0, iTabWidth, iTabHeight, Color( 255, 0, 0, 1 ) )

    -- draw.SimpleText( self._iCurrentTab, "Trebuchet24", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    
    surface.SetDrawColor( 65, 179, 131, 32 )
    surface.SetMaterial( oGradientMaterial )
    surface.DrawTexturedRect( self._iCursorPosEased, iTabHeight, iTabWidth, iTabHeight )
    
    draw.RoundedBox( 0, self._iCursorPosEased, iTabHeight + iTabHeight - iLowerBarHeight, iTabWidth, iLowerBarHeight, Color( 0, 209, 132) )
    
    return
end

function PANEL:OnRemove()
end

vgui.Register( "PRP.TabMenu", PANEL, "DPanel" )