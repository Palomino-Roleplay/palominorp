PRP.UI = PRP.UI or {}
PRP.UI.Nameplates = PRP.UI.Nameplates or {}

-- @TODO: Get a unified font for all UI elements
surface.CreateFont( "PRP.UI.Nameplates.Name", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    weight = 700,
    antialias = true,
} )

surface.CreateFont( "PRP.UI.Nameplates.Name.Blurred", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    blursize = 4,
    weight = 700,
    antialias = true,
} )

surface.CreateFont( "PRP.UI.Nameplates.ID", {
    font = "Oxygen Mono",
    size = 24 * PRP.UI.ScaleFactor,
    antialias = true,
} )

surface.CreateFont( "PRP.UI.Nameplates.Tag", {
    font = "Oxygen",
    weight = 700,
    size = 20 * PRP.UI.ScaleFactor,
    antialias = true,
    additive = true,
    -- shadow = true,
} )

surface.CreateFont( "PRP.UI.Nameplates.Tag.Blurred", {
    font = "Oxygen",
    weight = 700,
    size = 20 * PRP.UI.ScaleFactor,
    blursize = 3,
    antialias = true,
} )

function PRP.UI.Nameplates.Draw( pPlayer )
    local vPos = pPlayer:GetPos() + Vector( 0, 0, 80 )
    
    local iDistanceSqr = LocalPlayer():GetPos():DistToSqr( pPlayer:GetPos() )
    
    local iDistanceMultiplier = math.Clamp( 1 - ( ( iDistanceSqr - 40000 ) / 40000 ), 0, 1 )
    local iVoiceMultiplier = math.Clamp( pPlayer:VoiceVolume() * 2, 0, 1 )
    
    local iAlpha = math.Clamp( ( (iDistanceMultiplier * 0.25) + (0.75 * iVoiceMultiplier) ) * 255, 0, 255 )

    -- @TODO: Redo with TEXT_ALIGN_BOTTOM so the text is always same distance from the player
    
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag", vPos:ToScreen().x, vPos:ToScreen().y - (20 * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha * 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag.Blurred", vPos:ToScreen().x, vPos:ToScreen().y - (20 * PRP.UI.ScaleFactor), Color( 0, 255, 0, iAlpha * 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    
    -- Action
    -- draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", vPos:ToScreen().x, vPos:ToScreen().y, Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    -- draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", vPos:ToScreen().x, vPos:ToScreen().y + (32 * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha * 0.45 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    -- draw.SimpleText( "IN INVENTORY", "PRP.UI.Nameplates.Tag.Blurred", vPos:ToScreen().x, vPos:ToScreen().y + (32 - 20) * PRP.UI.ScaleFactor + 2, Color( 0, 0, 0, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    -- draw.SimpleText( "IN INVENTORY", "PRP.UI.Nameplates.Tag", vPos:ToScreen().x, vPos:ToScreen().y + (32 - 20) * PRP.UI.ScaleFactor, Color( 255, 206, 73, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    
    -- Equipping
    -- draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", vPos:ToScreen().x, vPos:ToScreen().y, Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    -- draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", vPos:ToScreen().x, vPos:ToScreen().y + (32 * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha * 0.45 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    -- draw.SimpleText( "EQUIPPING MP5", "PRP.UI.Nameplates.Tag.Blurred", vPos:ToScreen().x, vPos:ToScreen().y + (32 - 20) * PRP.UI.ScaleFactor + 2, Color( 0, 0, 0, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    -- draw.SimpleText( "EQUIPPING MP5", "PRP.UI.Nameplates.Tag", vPos:ToScreen().x, vPos:ToScreen().y + (32 - 20) * PRP.UI.ScaleFactor, Color( 255, 40, 40, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    -- Normal    
    draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name", vPos:ToScreen().x, vPos:ToScreen().y, Color( 137 + ( 118 * pPlayer:VoiceVolume() ), 191 + ( 64 * pPlayer:VoiceVolume() ), 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
    draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", vPos:ToScreen().x, vPos:ToScreen().y + (32 * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha * 0.15 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end

hook.Add( "HUDPaint", "PRP.UI.Nameplates.HUDPaint", function()
    for k, v in pairs( player.GetAll() ) do
        -- if v == LocalPlayer() then continue end
        PRP.UI.Nameplates.Draw( v )
    end
end )