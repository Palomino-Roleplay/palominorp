PRP.UI = PRP.UI or {}
PRP.UI.Nameplates = PRP.UI.Nameplates or {}

-- @TODO: Get a unified font for all UI elements
surface.CreateFont( "PRP.UI.Nameplates.Name", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    weight = 700,
    antialias = true,
    shadow = false
} )

surface.CreateFont( "PRP.UI.Nameplates.Name.Blurred", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    blursize = 6,
    weight = 700,
    antialias = true,
    shadow = false
} )

surface.CreateFont( "PRP.UI.Nameplates.ID", {
    font = "Oxygen Mono",
    size = 24 * PRP.UI.ScaleFactor,
    -- blursize = 3,
    antialias = true,
    shadow = false
} )

function PRP.UI.Nameplates.Draw( pPlayer )
    local vPos = pPlayer:GetPos() + Vector( 0, 0, 80 )

    -- Fade in from 300 to 200 distance
    local iDistance = LocalPlayer():GetPos():Distance( pPlayer:GetPos() )
    local iAlpha = math.Clamp( 255 - ( ( iDistance - 200 ) / 100 ) * 255, 0, 255 )

    draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name", vPos:ToScreen().x, vPos:ToScreen().y, Color( 137, 191, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    draw.SimpleText( "#" .. pPlayer:SteamID64(), "PRP.UI.Nameplates.ID", vPos:ToScreen().x, vPos:ToScreen().y + (32) * PRP.UI.ScaleFactor, Color( 255, 255, 255, iAlpha * 0.15 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end

hook.Add( "HUDPaint", "PRP.UI.Nameplates.HUDPaint", function()
    for k, v in pairs( player.GetAll() ) do
        if v == LocalPlayer() then continue end
        PRP.UI.Nameplates.Draw( v )
    end
end )