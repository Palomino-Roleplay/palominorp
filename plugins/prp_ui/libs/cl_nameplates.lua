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
        additive = true,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.Name.Blurred", {
        font = "Inter",
        size = iLargeFontSize * PRP.UI.ScaleFactor,
        blursize = ( iLargeFontSize * PRP.UI.ScaleFactor ) / 8,
        weight = 700,
        antialias = true,
        additive = false,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.Name.VeryBlurred", {
        font = "Inter",
        size = iLargeFontSize * PRP.UI.ScaleFactor,
        blursize = ( iLargeFontSize * PRP.UI.ScaleFactor ) / 3,
        weight = 700,
        antialias = true,
        additive = true,
    } )

    surface.CreateFont( "PRP.UI.Nameplates.ID", {
        font = "Oxygen Mono",
        size = iSmallFontSize * PRP.UI.ScaleFactor,
        antialias = true,
        additive = true,
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
        additive = true,
    } )
end

-- @TODO: Move to a config setting
local iNameplateDrawDistance = 4096
local iNameplateDrawDistanceSqr = math.pow( iNameplateDrawDistance, 2 )
local iNameplateFadeDistance = 128
local iNameplateFadeDistanceSqr = math.pow( iNameplateDrawDistance - iNameplateFadeDistance, 2 )


-- See: https://wiki.facepunch.com/gmod/Entity:GetBonePosition
local function GetNametagPos( pPlayer )
    local iEyesIndex = pPlayer:LookupAttachment( "eyes" )
    if not iEyesIndex or iEyesIndex == -1 then return pPlayer:GetPos() + Vector( 0, 0, 64 + 10 ), pPlayer:GetPos() end

    local tAttachment = pPlayer:GetAttachment( iEyesIndex )
    if not tAttachment then
        return pPlayer:GetPos() + Vector( 0, 0, 64 + 10 ), pPlayer:GetPos()
    end

    return tAttachment.Pos + ( pPlayer:GetUp() * 6 ), tAttachment.Pos
end

function PRP.UI.Nameplates.Draw( pPlayer, tScreenPos )
    local iDistanceSqr = LocalPlayer():GetPos():DistToSqr( pPlayer:GetPos() )

    -- @TODO: Apply the alpha multiplayer in the original function since we did the distance check there
    local iDistanceMultiplier = math.Clamp( 1 - ( ( iDistanceSqr - (iNameplateDrawDistanceSqr - iNameplateFadeDistanceSqr) ) / iNameplateFadeDistanceSqr ), 0, 1 )
    local iVoiceMultiplier = math.ease.OutCubic( pPlayer:VoiceVolume() )
    local iAlpha = math.Clamp( ( (iDistanceMultiplier * 0.25) + (0.75 * iVoiceMultiplier) ) * 255, 0, 255 )

    local bContextOpen = IsValid( g_ContextMenu ) and g_ContextMenu:IsVisible()



    local iYPos = tScreenPos.y

    --
    -- Character ID
    --
    local oIDColor = bContextOpen and Color( 255, 255, 255, iAlpha ) or Color( 255, 255, 255, iAlpha / 2 )
    draw.SimpleText(
        "#" .. string.format( "%04d", pPlayer:GetCharacter():GetID() ),
        "PRP.UI.Nameplates.ID",
        tScreenPos.x,
        tScreenPos.y,
        oIDColor,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_BOTTOM
    )



    iYPos = iYPos - iSmallFontSize + 16 * PRP.UI.ScaleFactor
    --
    -- Nametag
    --
    local oNametagColor = bContextOpen and Color( 255, 255, 255, iAlpha ) or Color(
        137 + ( 118 * pPlayer:VoiceVolume() ),
        191 + ( 64 * pPlayer:VoiceVolume() ),
        255,
        iAlpha / 2
    )
    local oActionColor = Color( 255, 206, 73, iDistanceMultiplier * 255 )
    local oShadowColor = oNametagColor

    local iMinHealthForEffect = 50
    if pPlayer:Health() < iMinHealthForEffect then
        local iLowHealthEffectMultiplier = ( iMinHealthForEffect - pPlayer:Health() ) / iMinHealthForEffect

        local oMaxColor = Color( 255, 137, 137, iAlpha / 2 )

        -- I know, I know. I'm sorry.
        -- This does a couple things:
        -- 1. Makes the color pulse
        -- 2. Pulse increases frequency with iLowHealthEffectMultiplier
        -- 3. Pulse is more intense with iLowHealthEffectMultiplier
        oShadowColor = PRP.Util.LerpColor(
            math.abs( math.sin( CurTime() * ( 3 + ( 4 * iLowHealthEffectMultiplier ) ) ) * iLowHealthEffectMultiplier
        ), oNametagColor, oMaxColor )

        -- Make main nametag more "red"
        -- local iNametagOldRed = oNametagColor.r
        -- oNametagColor.r = Lerp( iLowHealthEffectMultiplier, oNametagColor.r, oNametagColor.b )
        -- oNametagColor.g = Lerp( iLowHealthEffectMultiplier, oNametagColor.b, iNametagOldRed )
    end


    if pPlayer:GetNetVar( "actionString", nil ) then
        -- Name (Blurred)
        draw.SimpleText( pPlayer:Nick(), "PRP.UI.Nameplates.Name.Blurred", tScreenPos.x, iYPos, Color( 255, 255, 255, iAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )


        -- Action

        -- Center it over the name
        iYPos = iYPos - ( ( iLargeFontSize - iSmallFontSize ) / 2 )

        local sActionString = pPlayer:GetNetVar( "actionString", "" )
        if (sActionString:sub(1, 1) == "@") then
            sActionString = L2(sActionString:sub(2)) or sActionString
        end

        draw.SimpleText( string.upper( sActionString ), "PRP.UI.Nameplates.Tag.Blurred", tScreenPos.x, iYPos, oActionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( string.upper( sActionString ), "PRP.UI.Nameplates.Tag", tScreenPos.x, iYPos, oActionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    else
        if pPlayer:IsDisguised() then
            -- Draw a blur if the player is disguised (has a mask on)
            draw.SimpleText(
                "Unknown Person",
                "PRP.UI.Nameplates.Name.VeryBlurred",
                tScreenPos.x,
                iYPos,
                oNametagColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )
        else
            -- Glow
            draw.SimpleText(
                pPlayer:Nick(),
                "PRP.UI.Nameplates.Name.Blurred",
                tScreenPos.x,
                iYPos,
                oShadowColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )

            -- Name
            draw.SimpleText(
                pPlayer:Nick(),
                "PRP.UI.Nameplates.Name",
                tScreenPos.x,
                iYPos,
                oNametagColor,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_BOTTOM
            )
        end
    end

    iYPos = iYPos - iLargeFontSize + 0 * PRP.UI.ScaleFactor
    --
    -- New Player
    --

    -- local oNewPlayerTextColor = Color( 255, 255, 255, iAlpha / 2 )
    -- local oNewPlayerShadowColor = Color( 128, 255, 128, iAlpha / 2 )
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag", tScreenPos.x, iYPos, oNewPlayerTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    -- draw.SimpleText( "NEW PLAYER", "PRP.UI.Nameplates.Tag.Blurred", tScreenPos.x, iYPos, oNewPlayerShadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

end

function PLUGIN:PostDrawTranslucentRenderables()
    for _, pPlayer in pairs( player.GetAll() ) do
        if not IsValid( pPlayer ) then continue end
        -- if pPlayer == LocalPlayer() then continue end
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
        local vOurAimVector = EyeVector()
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

        -- if pPlayer == LocalPlayer() then
        --     aAngles:RotateAroundAxis( aAngles:Right(), 180 )
        -- end

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