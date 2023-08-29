PRP.UI = PRP.UI or {}
PRP.UI.Nameplates = PRP.UI.Nameplates or {}

-- @TODO: Get a unified font for all UI elements

local iLargeFontSize = 156
local iSmallFontSize = 108

function PLUGIN:InitializedPlugins()
    surface.CreateFont( "PRP.UI.Nameplates.Name", {
        font = "Inter",
        size = iLargeFontSize * PRP.UI.ScaleFactor,
        weight = 700,
        antialias = true,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.Name.Blurred", {
        font = "Inter",
        size = iLargeFontSize * PRP.UI.ScaleFactor,
        blursize = ( iLargeFontSize * PRP.UI.ScaleFactor ) / 8,
        weight = 700,
        antialias = true,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.ID", {
        font = "Oxygen Mono",
        size = iSmallFontSize * PRP.UI.ScaleFactor,
        antialias = true,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.Tag", {
        font = "Oxygen",
        weight = 700,
        size = iSmallFontSize * PRP.UI.ScaleFactor,
        antialias = true,
        additive = true,
        -- shadow = true,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.Tag.Blurred", {
        font = "Oxygen",
        weight = 700,
        size = iSmallFontSize * PRP.UI.ScaleFactor,
        blursize = ( iSmallFontSize * PRP.UI.ScaleFactor ) / 4,
        antialias = true,
    } )
end

-- @TODO: Move to a config setting
local iNameplateDrawDistance = 256
local iNameplateDrawDistanceSqr = math.pow( iNameplateDrawDistance, 2 )
local iNameplateFadeDistance = 64
local iNameplateFadeDistanceSqr = math.pow( iNameplateDrawDistance - iNameplateFadeDistance, 2 )


-- See: https://wiki.facepunch.com/gmod/Entity:GetBonePosition
local function GetNametagPos( pPlayer )
    local iEyesIndex = pPlayer:LookupAttachment( "eyes" )
    if not iEyesIndex then return pPlayer:GetPos() + Vector( 0, 0, 64 + 10 ), pPlayer:GetPos() end

    local tAttachment = pPlayer:GetAttachment( iEyesIndex )

    return tAttachment.Pos + ( pPlayer:GetUp() * 6 ), tAttachment.Pos
end

function PRP.UI.Nameplates.Draw( pPlayer, tScreenPos )
    -- local vPos = GetNametagPos( pPlayer ) + Vector( 0, 0, 10 )

    local iDistanceSqr = LocalPlayer():GetPos():DistToSqr( pPlayer:GetPos() )

    local iDistanceMultiplier = math.Clamp( 1 - ( ( iDistanceSqr - (iNameplateDrawDistanceSqr - iNameplateFadeDistanceSqr) ) / iNameplateFadeDistanceSqr ), 0, 1 )
    local iVoiceMultiplier = math.ease.OutCubic( pPlayer:VoiceVolume() )

    local iAlpha = math.Clamp( ( (iDistanceMultiplier * 0.25) + (0.75 * iVoiceMultiplier) ) * 255, 0, 255 )

    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag", tScreenPos.x, tScreenPos.y - (20 + 4 + iLargeFontSize * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha * 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag.Blurred", tScreenPos.x, tScreenPos.y - (20 + 4 + iLargeFontSize * PRP.UI.ScaleFactor), Color( 0, 255, 0, iAlpha * 1 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- Equipping
    -- draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", tScreenPos.x, tScreenPos.y - ((20 + 4) * PRP.UI.ScaleFactor), Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", tScreenPos.x, tScreenPos.y, Color( 255, 255, 255, iAlpha * 0.45 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- draw.SimpleText( "EQUIPPING MP5", "PRP.UI.Nameplates.Tag.Blurred", tScreenPos.x, tScreenPos.y - ((20 + 4 + 3) * PRP.UI.ScaleFactor), Color( 0, 0, 0, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "EQUIPPING MP5", "PRP.UI.Nameplates.Tag", tScreenPos.x, tScreenPos.y - ((20 + 4 + 3) * PRP.UI.ScaleFactor), Color( 255, 40, 40, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- ID #
    local iYPos = tScreenPos.y
    draw.SimpleText( "#" .. string.format( "%06d", pPlayer:GetCharacter():GetID() ), "PRP.UI.Nameplates.ID", tScreenPos.x, tScreenPos.y, Color( 255, 255, 255, iAlpha * 0.45 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- RP Name
    iYPos = iYPos - ((iSmallFontSize + 4) * PRP.UI.ScaleFactor)
    if pPlayer:GetNetVar( "actionString", nil ) then
        -- Name (Blurred)
        draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", tScreenPos.x, iYPos, Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        -- Action
        iYPos = iYPos - (3 * PRP.UI.ScaleFactor)
        local sActionString = pPlayer:GetNetVar( "actionString", "" )

        if (sActionString:sub(1, 1) == "@") then
            sActionString = L2(sActionString:sub(2)) or sActionString
        end

        draw.SimpleText( string.upper( sActionString ), "PRP.UI.Nameplates.Tag.Blurred", tScreenPos.x, iYPos, Color( 0, 0, 0, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( string.upper( sActionString ), "PRP.UI.Nameplates.Tag", tScreenPos.x, iYPos, Color( 255, 206, 73, iDistanceMultiplier * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    else
        draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name", tScreenPos.x, iYPos, Color( 137 + ( 26 * pPlayer:VoiceVolume() ), 191 + ( 64 * pPlayer:VoiceVolume() ), 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end
end

hook.Add( "HUDPaint", "PRP.UI.Nameplates.HUDPaint", function()
    for k, pPlayer in pairs( player.GetAll() ) do
        if not IsValid( pPlayer ) then continue end
        if pPlayer == LocalPlayer() then continue end
        if not pPlayer:Alive() then continue end
        if not pPlayer:GetCharacter() then continue end
        if pPlayer:GetNoDraw() then continue end
        if pPlayer:IsDormant() then continue end
        if pPlayer:GetColor().a == 0 and ( pPlayer:GetRenderMode() == RENDERMODE_TRANSALPHA or pPlayer:GetRenderMode() == RENDERMODE_TRANSCOLOR ) then continue end
        if pPlayer:GetPos():DistToSqr( LocalPlayer():GetPos() ) > iNameplateDrawDistanceSqr then continue end

        local vNametagPos, vHeadPos = GetNametagPos( pPlayer )

        -- @TODO: Probably a little too expensive for HUDPaint. Can we do this some other way?
        -- Don't display if player obstructed
        local tTrace = util.TraceLine({
            start = LocalPlayer():EyePos(),
            endpos = vHeadPos,
            filter = LocalPlayer(),
            mask = MASK_SHOT_HULL,
        })

        if tTrace.Entity ~= pPlayer then continue end

        -- PRP.UI.Nameplates.Draw( pPlayer )
    end
end )

function PLUGIN:PostDrawTranslucentRenderables()
    for _, pPlayer in pairs( player.GetAll() ) do
        if not IsValid( pPlayer ) then continue end
        if pPlayer == LocalPlayer() then continue end
        if not pPlayer:Alive() then continue end
        if not pPlayer:GetCharacter() then continue end
        if pPlayer:GetNoDraw() then continue end
        if pPlayer:IsDormant() then continue end
        if pPlayer:GetColor().a == 0 and ( pPlayer:GetRenderMode() == RENDERMODE_TRANSALPHA or pPlayer:GetRenderMode() == RENDERMODE_TRANSCOLOR ) then continue end
        if pPlayer:GetPos():DistToSqr( LocalPlayer():GetPos() ) > iNameplateDrawDistanceSqr then continue end

        local vNametagPos, vHeadPos = GetNametagPos( pPlayer )

        -- @TODO: Probably a little too expensive for HUDPaint. Can we do this some other way?
        -- Don't display if player obstructed
        local tTrace = util.TraceLine({
            start = LocalPlayer():EyePos(),
            endpos = vHeadPos,
            filter = LocalPlayer(),
            -- mask = MASK_SHOT_HULL,
        })

        if tTrace.Entity ~= pPlayer then continue end

        -- Drawing below this point.

        local vOurEyePos = LocalPlayer():EyePos()
        local vTheirEyePos = pPlayer:EyePos()

        local vLookPos = vNametagPos - vOurEyePos
        vLookPos:Normalize()

        -- Condition 1: LocalPlayer looking at nameplate
        local vUnitPos = (vNametagPos - vOurEyePos)
        vUnitPos.z = 0
        vUnitPos:Normalize()
        local vOurAimVector = LocalPlayer():GetAimVector()
        vOurAimVector.z = 0
        local iAimDiff = vUnitPos:Dot( vOurAimVector )

        local iOurMinAimDiff = 0.6
        if iAimDiff < iOurMinAimDiff then continue end

        -- Condition 2: Other player looking at LocalPlayer
        local vLookAtLocalPlayer = vOurEyePos - vTheirEyePos
        vLookAtLocalPlayer.z = 0
        vLookAtLocalPlayer:Normalize()
        local vTheirAimVector = pPlayer:GetAimVector()
        vTheirAimVector.z = 0
        vTheirAimVector:Normalize()
        local theirAimDiff = vLookAtLocalPlayer:Dot( vTheirAimVector )

        local iTheirMinAimDiff = -0.5
        if ( pPlayer:VoiceVolume() == 0 and not pPlayer:GetNetVar( "actionString", nil ) ) and theirAimDiff < iTheirMinAimDiff then continue end  -- -1 for exact opposite, < -0.99 gives a tiny bit of leeway

        local iAlpha = 255

        -- Our aim diff alpha multiplier
        local iOurAimDiffAlphaMultiplier = (iAimDiff - iOurMinAimDiff) / (1 - iOurMinAimDiff)
        iAlpha = iAlpha * iOurAimDiffAlphaMultiplier

        local iTheirAimDiffAlphaMultiplier = ( pPlayer:GetNetVar( "actionString", nil ) and 1 or math.max( math.ease.OutExpo( pPlayer:VoiceVolume() ), (theirAimDiff - iTheirMinAimDiff) / (1 - iTheirMinAimDiff) ) )
        iAlpha = iAlpha * iTheirAimDiffAlphaMultiplier

        local aAngles = (vOurEyePos - vNametagPos):Angle()
        aAngles.p = 0
        aAngles:Normalize()
        aAngles:RotateAroundAxis( aAngles:Forward(), 90 )
        aAngles:RotateAroundAxis( aAngles:Right(), -90 )

        -- local aAngles = pPlayer:EyeAngles()
        -- aAngles.p = 0
        -- aAngles:Normalize()
        -- aAngles:RotateAroundAxis( aAngles:Forward(), 90 )
        -- aAngles:RotateAroundAxis( aAngles:Right(), -90 )


        surface.SetAlphaMultiplier( iAlpha / 255 )

        cam.Start3D2D( vNametagPos, aAngles, 0.02 )
            PRP.UI.Nameplates.Draw( pPlayer, { x = 0, y = 0 } )
        cam.End3D2D()

        surface.SetAlphaMultiplier( 1 )
    end
end