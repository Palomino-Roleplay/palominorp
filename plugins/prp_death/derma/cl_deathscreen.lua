PRP.UI = PRP.UI or {}

surface.CreateFont( "PRP.UI.DeathScreen.Heading", {
    font = "Inter",
    size = 64 * PRP.UI.ScaleFactor,
    weight = 700,
    antialias = true
} )

surface.CreateFont( "PRP.UI.DeathScreen.Subheading", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    weight = 500,
    antialias = true
} )

surface.CreateFont( "PRP.UI.DeathScreen.Info", {
    font = "Inter",
    size = 16 * PRP.UI.ScaleFactor,
    weight = 500,
    antialias = true
} )

local PANEL = {}

function PANEL:Init()
    self:SetPos( 0, 0 )
    self:SetSize( ScrW(), ScrH() )
end

function PANEL:Close()
    -- @TODO: Fade out animation (look at helix death screen)
    self:Remove()
end

function PANEL:Paint( w, h )
    local iFullDeathTimestamp = LocalPlayer():GetNetVar("deathTimeFull", false)
    local iFastDeathTimestamp = LocalPlayer():GetNetVar("deathTimeFast", false)

    if not iFastDeathTimestamp or not iFullDeathTimestamp then return end

    surface.SetDrawColor( 0, 0, 0, 255 )
    surface.DrawRect( 0, 0, w, h )

    local iSecondsUntilFullRespawn = math.ceil( iFullDeathTimestamp - CurTime() )
    local iSecondsUntilFastRespawn = math.ceil( iFastDeathTimestamp - CurTime() )

    local sFormattedFullRespawnTime = iSecondsUntilFullRespawn <= 0 and "momentarily." or "in " .. string.FormattedTime( iSecondsUntilFullRespawn, "%02i:%02i" )
    local sFormattedFastRespawnTime = iSecondsUntilFastRespawn <= 0 and "anytime." or "in " .. string.FormattedTime( iSecondsUntilFastRespawn, "%02i:%02i" )

    draw.SimpleText( "You are unconscious.", "PRP.UI.DeathScreen.Heading", w / 2, h / 2 - (64 + 10) * PRP.UI.ScaleFactor, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( "You will respawn in " .. sFormattedFullRespawnTime, "PRP.UI.DeathScreen.Subheading", w / 2, h / 2 - 32 * PRP.UI.ScaleFactor, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( "If you don't want to wait for a paramedic to revive you,", "PRP.UI.DeathScreen.Info", w / 2, h / 2 + (32 + 5) * PRP.UI.ScaleFactor, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( "you can press [SPACE] to respawn " .. sFormattedFastRespawnTime, "PRP.UI.DeathScreen.Info", w / 2, h / 2 + (48 + 5) * PRP.UI.ScaleFactor, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "PRP.DeathScreen", PANEL, "DPanel" )