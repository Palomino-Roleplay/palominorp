local PANEL = {}

surface.CreateFont( "PRP.DeathScreen.Title", {
    font = "Inter Bold",
    size = 200,
    antialias = true
})

surface.CreateFont( "PRP.DeathScreen.Title.Shadow", {
    font = "Inter Bold",
    size = 200,
    antialias = true,
    blursize = 32
})

local tDeathMessages = {
    "SMOKED",
    "DEAD",
    "WASTED",
    "FRAGGED",
    "KILLED",
    "ERASED",
    "OWNED",
    "GONE",
    "DROPPED",
    "CLIPPED",
}

function PANEL:Init()
    -- oDeathSound:PlayEx( 1, 100 )
    -- oDeathSound:SetDSP( 0 )

    surface.PlaySound( "palomino/death_2.wav" )

    -- surface.PlaySound( "palomino/death.mp3" )

    self.message = table.Random( tDeathMessages )

    self:SetPos( 0, 0 )
    self:SetSize( ScrW(), ScrH() )
    self:SetZPos( 1000 )

    self.m_iFadeToWhiteStartTimestamp = 7.5
    self.m_iFadeToWhiteEndTimestamp = 8

    self.m_iInitTime = SysTime()
    self.m_iTotalTime = 15

    self.m_dCloseButton = vgui.Create( "DButton", self )
    self.m_dCloseButton:SetSize( 32, 32 )
    self.m_dCloseButton:SetPos( ScrW() - 32 - 32, 32 )
    self.m_dCloseButton:SetText( "X" )
    self.m_dCloseButton.DoClick = function()
        self:Remove()
    end

    self.m_iWhiteFadeFactor = 0
    self.m_iFadeOutTimestamp = 0

    timer.Simple( self.m_iTotalTime, function()
        if IsValid( self ) then
            self:Remove()
        end
    end )
end

function PANEL:Paint( iW, iH )
    local iTime = SysTime() - self.m_iInitTime

    local iFadeTime = 0
    local iFadeAlpha = 255
    if self.m_iFadeOutTimestamp > 0 then
        iFadeTime = SysTime() - self.m_iFadeOutTimestamp
        iFadeAlpha = ( 1 - math.ease.InExpo( iFadeTime / 8 ) ) * 255
        if iFadeAlpha <= 0 then
            self:Remove()
        end
    end

    local iFadeToWhiteFactor = 0
    if iTime > self.m_iFadeToWhiteEndTimestamp then
        -- 1 to 0 from the end of the fade to white to the end of the death screen
        iFadeToWhiteFactor = 1 - math.Clamp( ( iTime - self.m_iFadeToWhiteEndTimestamp ) / ( self.m_iTotalTime - self.m_iFadeToWhiteEndTimestamp ), 0, 1 )
    elseif iTime > self.m_iFadeToWhiteStartTimestamp then
        -- A number that increases from 0 to 1 over the course of the fade to white
        iFadeToWhiteFactor = math.ease.InExpo( math.Clamp( ( iTime - self.m_iFadeToWhiteStartTimestamp ) / ( self.m_iFadeToWhiteEndTimestamp - self.m_iFadeToWhiteStartTimestamp ), 0, 1 ) )
    end

    local iAnimationFactor = math.ease.OutExpo( math.Clamp( iTime / 8, 0, 1 ) )

    if iTime < self.m_iFadeToWhiteEndTimestamp then
        surface.SetDrawColor( 64 * (1 - iAnimationFactor), 0, 0, iFadeAlpha )
        surface.DrawRect( 0, 0, iW, iH )
    end

    surface.SetDrawColor( 255, 255, 255, 255 * iFadeToWhiteFactor )
    surface.DrawRect( 0, 0, iW, iH )

    if iTime < self.m_iFadeToWhiteEndTimestamp then
        -- Shadow
        surface.SetFont( "PRP.DeathScreen.Title.Shadow" )
        local iTextShadowW, iTextShadowH = surface.GetTextSize( self.message )
        surface.SetTextColor( 255 - 155 * iAnimationFactor, ( 1 - iAnimationFactor ) * 255, ( 1 - iAnimationFactor ) * 255, 64 + 128 * ( 1 - iAnimationFactor ) )
        surface.SetTextPos( iW / 2 - iTextShadowW / 2, iH / 2 - iTextShadowH / 2 )
        surface.DrawText( self.message )

        -- Text

        surface.SetFont( "PRP.DeathScreen.Title" )
        local iTextW, iTextH = surface.GetTextSize( self.message )

        if iFadeToWhiteFactor > 0 then
            print("ass")
            surface.SetTextColor( 100 + 155 * iFadeToWhiteFactor, iFadeToWhiteFactor * 255, iFadeToWhiteFactor * 255, 255 )
        else
            print("tities")
            surface.SetTextColor( 255 - 155 * iAnimationFactor, ( 1 - iAnimationFactor ) * 255, ( 1 - iAnimationFactor ) * 255, 255 )
        end

        surface.SetTextPos( iW / 2 - iTextW / 2, iH / 2 - iTextH / 2 )
        surface.DrawText( self.message )
    end
end

function PANEL:FadeOut()
    self.m_iFadeOutTimestamp = SysTime()
end

vgui.Register( "PRP.DeathScreen", PANEL, "DPanel" )

concommand.Add( "prp_deathscreen", function()
    PRP.DeathScreen = vgui.Create( "PRP.DeathScreen" )
end )

gameevent.Listen( "player_spawn" )
hook.Add( "player_spawn", "player_spawn_example", function( data ) 
    -- ix.gui.deathScreen.m_iFadeOutTimestamp = SysTime()
end )