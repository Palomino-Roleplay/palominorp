PRP.UI = PRP.UI or {}
PRP.UI.Nameplates = PRP.UI.Nameplates or {}

-- @TODO: Get a unified font for all UI elements

function PLUGIN:InitializedPlugins()
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
end


function PRP.UI.Nameplates.Draw( pPlayer )
    local vPos = pPlayer:GetPos() + Vector( 0, 0, 64 + 10 )
    
    local iDistanceSqr = LocalPlayer():GetPos():DistToSqr( pPlayer:GetPos() )
    
    local iDistanceMultiplier = math.Clamp( 1 - ( ( iDistanceSqr - 40000 ) / 40000 ), 0, 1 )
    local iVoiceMultiplier = math.Clamp( pPlayer:VoiceVolume() * 2, 0, 1 )
    
    local iAlpha = math.Clamp( ( (iDistanceMultiplier * 0.25) + (0.75 * iVoiceMultiplier) ) * 255, 0, 255 )
    
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag", vPos:ToScreen().x, vPos:ToScreen().y - (20 + 4 + 32 * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha * 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag.Blurred", vPos:ToScreen().x, vPos:ToScreen().y - (20 + 4 + 32 * PRP.UI.ScaleFactor), Color( 0, 255, 0, iAlpha * 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- Equipping
    -- draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", vPos:ToScreen().x, vPos:ToScreen().y - ((20 + 4) * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", vPos:ToScreen().x, vPos:ToScreen().y, Color( 255, 255, 255, iAlpha * 0.45 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- draw.SimpleText( "EQUIPPING MP5", "PRP.UI.Nameplates.Tag.Blurred", vPos:ToScreen().x, vPos:ToScreen().y - ((20 + 4 + 3) * PRP.UI.ScaleFactor), Color( 0, 0, 0, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "EQUIPPING MP5", "PRP.UI.Nameplates.Tag", vPos:ToScreen().x, vPos:ToScreen().y - ((20 + 4 + 3) * PRP.UI.ScaleFactor), Color( 255, 40, 40, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- ID #
    local iYPos = vPos:ToScreen().y
    draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", vPos:ToScreen().x, vPos:ToScreen().y, Color( 255, 255, 255, iAlpha * 0.45 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    
    -- RP Name
    if pPlayer:GetNetVar( "actionString", nil ) then
        -- Name (Blurred)
        iYPos = iYPos - ((20 + 4) * PRP.UI.ScaleFactor)
        draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", vPos:ToScreen().x, iYPos, Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        -- Action
        iYPos = iYPos - (3 * PRP.UI.ScaleFactor)
        draw.SimpleText( string.upper( pPlayer:GetNetVar( "actionString", "" ) ), "PRP.UI.Nameplates.Tag.Blurred", vPos:ToScreen().x, iYPos, Color( 0, 0, 0, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( string.upper( pPlayer:GetNetVar( "actionString", "" ) ), "PRP.UI.Nameplates.Tag", vPos:ToScreen().x, iYPos, Color( 255, 206, 73, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    
    else    
        iYPos = iYPos - ((20 + 4) * PRP.UI.ScaleFactor)
        draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name", vPos:ToScreen().x, iYPos, Color( 137 + ( 118 * pPlayer:VoiceVolume() ), 191 + ( 64 * pPlayer:VoiceVolume() ), 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end

    -- Developer Settings
    if GetConVar( "developer" ):GetBool() and LocalPlayer():IsAdmin() then
        local tPlyFaction = ix.faction.Get(pPlayer:Team())

        iYPos = iYPos - (32 * PRP.UI.ScaleFactor)
        draw.SimpleText( tPlyFaction.name .. ( pPlayer:GetCharacter():GetClass() and (" (" .. (ix.class.Get(pPlayer:GetCharacter():GetClass()).name) .. ")") or ""), "DebugFixed", vPos:ToScreen().x, iYPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        
        iYPos = iYPos - (12 * PRP.UI.ScaleFactor)
        draw.SimpleText( "Distance: " .. math.Round( LocalPlayer():GetPos():Distance( pPlayer:GetPos() ), 2 ), "DebugFixed", vPos:ToScreen().x, iYPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        iYPos = iYPos - (12 * PRP.UI.ScaleFactor)
        draw.SimpleText( "Armor: " .. pPlayer:Armor(), "DebugFixed", vPos:ToScreen().x, iYPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        iYPos = iYPos - (12 * PRP.UI.ScaleFactor)
        draw.SimpleText( "HP: " .. pPlayer:Health(), "DebugFixed", vPos:ToScreen().x, iYPos, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        iYPos = iYPos - (20 * PRP.UI.ScaleFactor)
        draw.SimpleText( pPlayer:SteamName(), "Trebuchet24", vPos:ToScreen().x, iYPos, tPlyFaction.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end
end

hook.Add( "HUDPaint", "PRP.UI.Nameplates.HUDPaint", function()
    for k, v in pairs( player.GetAll() ) do
        if not IsValid( v ) then continue end
        if not v:GetCharacter() then continue end
        if v == LocalPlayer() and not ix.config.Get( "DeveloperMode", false ) then continue end
        if not v:Alive() then continue end
        if v:GetNoDraw() then continue end
        if v:GetMoveType() == MOVETYPE_NOCLIP then continue end
        if v:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 80000 then continue end

        -- @TODO: Probably a little too expensive for HUDPaint. Can we do this some other way?
        -- Don't display if player obstructed
        local tTrace = util.QuickTrace( LocalPlayer():GetShootPos(), v:GetPos() - LocalPlayer():GetShootPos(), LocalPlayer() )
        if IsValid( tTrace.Entity ) and tTrace.Entity ~= v then continue end

        PRP.UI.Nameplates.Draw( v )
    end
end )