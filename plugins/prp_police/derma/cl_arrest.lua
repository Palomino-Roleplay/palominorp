local PANEL = {}

AccessorFunc( PANEL, "m_pTarget", "Target" )

function PANEL:Init()
    self:SetSize( 500, 300 )
    self:SetTitle( "Ticket Menu" )
    self:Center()
    self:MakePopup()

    self.canvas = vgui.Create( "DPanel", self )
    self.canvas:Dock( FILL )
    self.canvas:DockPadding( 10, 10, 10, 10 )

    self.amountLabel = self.canvas:Add( "ixLabel" )
    self.amountLabel:SetText( "Length" )
    self.amountLabel:SetFont( "ixSmallTitleFont" )
    self.amountLabel:SizeToContents()
    self.amountLabel:Dock(TOP)

    self.amount = self.canvas:Add( "ixNumSlider" )
    self.amount:Dock(TOP)
    self.amount:SetHeight( 50 )
    self.amount:SetMin( 1 )
    self.amount:SetMax( 30 )
    self.amount:SetValue( 10 )

    self.reasonLabel = self.canvas:Add( "ixLabel" )
    self.reasonLabel:SetText( "Reason" )
    self.reasonLabel:SetFont( "ixSmallTitleFont" )
    self.reasonLabel:SizeToContents()
    self.reasonLabel:Dock(TOP)

    self.reason = self.canvas:Add( "ixTextEntry" )
    self.reason:SetFont("ixMenuButtonFont")
    self.reason:Dock(TOP)

    self.submit = self.canvas:Add( "ixMenuButton" )
    self.submit:SetText( "Arrest" )
    self.submit:Dock(BOTTOM)
    self.submit:SetHeight( 50 )
    self.submit:SetContentAlignment( 5 )
    self.submit.DoClick = function()
        if self.reason:GetValue():len() > 100 then
            LocalPlayer():Notify( "Reason is too long." )
            return
        end

        if not self:GetTarget() or not IsValid( self:GetTarget() ) then
            LocalPlayer():Notify( "Player is no longer valid." )
            return
        end

        net.Start( "PRP.Police.Arrest" )
            net.WriteEntity( self:GetTarget() )
            net.WriteUInt( self.amount:GetValue(), 32 )
            net.WriteString( self.reason:GetValue() )
        net.SendToServer()
        self:Remove()
    end
end

vgui.Register( "PRP.Police.ArrestMenu", PANEL, "DFrame" )