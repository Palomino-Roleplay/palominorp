PRP.UI = PRP.UI or {}

local PANEL = {}

AccessorFunc( PANEL, "m_pEntity", "Entity" )

function PANEL:Init()
    self:SetSize( PRP.UI.ScaleFactor * 420, PRP.UI.ScaleFactor * 720 )
    self:Center()
    self:MakePopup()

    -- Text of phone number
    self.m_pPhoneNumber = self:Add( "DLabel" )
    self.m_pPhoneNumber:Dock( TOP )
    self.m_pPhoneNumber:DockMargin( 0, 0, 0, 10 )
    self.m_pPhoneNumber:SetFont( "PRP.PlyMenu.Large" )
    self.m_pPhoneNumber:SetTextColor( PUI.WHITE )
    self.m_pPhoneNumber:SetText( "" )
    self.m_pPhoneNumber:SetContentAlignment( 5 )
    self.m_pPhoneNumber:SetTall( PRP.UI.ScaleFactor * 50 )


    -- DIconPanel of phone keyboard
    self.m_pIconLayout = self:Add( "DIconLayout" )
    self.m_pIconLayout:Dock( FILL )
    self.m_pIconLayout:SetSpaceX( 5 )
    self.m_pIconLayout:SetSpaceY( 5 )

    for i = 1, 12 do
        local strText = tostring( i )

        if i == 10 then
            strText = "*"
        elseif i == 11 then
            strText = "0"
        elseif i == 12 then
            strText = "←"
        end

        local pButton = self.m_pIconLayout:Add( "DButton" )
        pButton:SetSize( PRP.UI.ScaleFactor * 100, PRP.UI.ScaleFactor * 100 )
        pButton:DockMargin( 5, 5, 5, 5 )
        pButton:SetText( strText )
        pButton:SetFont( "PRP.PlyMenu.Large" )
        pButton:SetTextColor( PUI.WHITE )
        pButton.Paint = function( _, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, PUI.BLACK )
        end
        pButton.DoClick = function()
            surface.PlaySound( "buttons/button12.wav" )
            if i == 12 then
                self.m_pPhoneNumber:SetText( self.m_pPhoneNumber:GetText():sub( 1, -2 ) )
            else
                self.m_pPhoneNumber:SetText( self.m_pPhoneNumber:GetText() .. strText )
            end
        end
    end

    local pCallButton = self.m_pIconLayout:Add( "DButton" )
    pCallButton:SetSize( PRP.UI.ScaleFactor * 105 * 3 - 5, PRP.UI.ScaleFactor * 100 )
    pCallButton:DockMargin( 5, 5, 5, 5 )
    pCallButton:SetText( "Call" )
    pCallButton:SetFont( "PRP.PlyMenu.Large" )
    pCallButton:SetTextColor( PUI.WHITE )
    pCallButton.Paint = function( _, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, PUI.GREEN )
    end
end

vgui.Register( "PRP.Payphone.Menu", PANEL, "DFrame" )