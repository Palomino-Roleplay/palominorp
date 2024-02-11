PRP.UI = PRP.UI or {}

local oHeartNoAlphatest = Material( "prp/icons/hud/heart.png" )

local oMaterialHeart = Material( "prp/icons/hud/heart_shadow.png" )

local oGradientLeft = Material( "prp/icons/hud/gradient_left.png" )

function fnHealthPercentSmoothed()
    return LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
end

local function fnArmorPercentSmoothed()
    return LocalPlayer():Armor() / 100
end

-- @TODO: Fonts and such
surface.CreateFont( "PRP.UI.Timer.Label", {
    font = "Inter",
    size = 14,
    weight = 600,
    antialias = true
})

surface.CreateFont( "PRP.UI.Timer.Time", {
    font = "Inter",
    size = 24,
    weight = 700,
    antialias = true
} )

surface.CreateFont( "PRP.UI.Watermark.Header", {
    font = "Inter",
    size = 16,
    weight = 700,
    antialias = true
})

surface.CreateFont( "PRP.UI.Watermark.Subtext", {
    font = "Inter",
    size = 12,
    weight = 300,
    antialias = true
})

surface.CreateFont( "PRP.UI.Bar.Label", {
    font = "Inter",
    size = 20,
    weight = 600,
    antialias = true
})

surface.CreateFont( "PRP.UI.Hint.Label", {
    font = "Inter",
    size = 20,
    weight = 600,
    antialias = true
})

function PRP.UI.DrawTimer( iX, iY, sLabel, iTime )
    local sTime = string.FormattedTime( iTime, "%02i:%02i" )

    surface.SetFont( "PRP.UI.Timer.Label" )
    local iLabelWidth, iLabelHeight = surface.GetTextSize( sLabel )
    surface.SetTextColor( 255, 255, 255, 100 )
    surface.SetTextPos( iX, iY )
    surface.DrawText( sLabel )

    surface.SetFont( "PRP.UI.Timer.Time" )
    local iTimeWidth, iTimeHeight = surface.GetTextSize( sTime )
    surface.SetTextColor( 255, 255, 255, 255 )
    surface.SetTextPos( iX + iLabelWidth + 10, iY + (iLabelHeight - iTimeHeight) / 2 )
    surface.DrawText( sTime )
end

local oBarPill = Material( "prp/icons/hud/healthbar_pill_5pxc.png" )
function PRP.UI.DrawBar( oMaterial, iX, iY, fnPercent, oColor, bDrawValue )
    oColor = oColor or COLOR_WHITE

    local iXPadding = 16
	local iYPadding = 20

    local iXGap = 16

    local iIconWidth = 24
    local iIconHeight = 24

    -- Print("IconHeight: " .. iIconHeight)
    -- Print("IconWidth: " .. iIconWidth)
    local iIconX = iX
    local iIconY = iY

    surface.SetMaterial( oMaterial )
    surface.SetDrawColor( oColor:Unpack() )
    surface.DrawTexturedRect( iIconX, iIconY, iIconWidth, iIconHeight )

    -- Bar background

    local iBarWidth = bDrawValue and 330 or 365
    local iBarHeight = 5
    local iBarX = iIconX + iIconWidth + iXGap
    local iBarY = iIconY + ( iIconHeight / 2 ) - ( iBarHeight / 2 )

    -- Give a touch of contrast in dark areas
    surface.SetDrawColor( 255, 255, 255, 1 )
    surface.DrawRect( iBarX, iBarY, iBarWidth, iBarHeight )

    -- Overlay background
    render.OverrideBlend(
        true,
        BLEND_DST_COLOR,
        BLEND_SRC_COLOR,
        BLENDFUNC_ADD
    )

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawRect( iBarX, iBarY, iBarWidth, iBarHeight )

    render.OverrideBlend( false )

    -- Bar Progress

    -- Bar Progress - Gradient
    surface.SetMaterial( oGradientLeft )
    surface.SetDrawColor( ColorAlpha( oColor, 48 ):Unpack() )
    surface.DrawTexturedRectUV(
        iBarX,
        iBarY,
        iBarWidth * fnPercent(),
        iBarHeight,
        -- u1
        1 - fnPercent(),
        -- v1
        0,
        -- u2
        1,
        -- v2
        1
    )

    -- Bar Progress - Pill
    local iBarPillWidth = oBarPill:Width()
    local iBarPillHeight = oBarPill:Height()

    local iBarPillX = iBarX + iBarWidth * fnPercent() - iBarPillWidth / 2
    local iBarPillY = iBarY

    surface.SetMaterial( oBarPill )
    surface.SetDrawColor( ColorAlpha( oColor, 255 ):Unpack() )
    surface.DrawTexturedRect( iBarPillX, iBarPillY, iBarPillWidth, iBarPillHeight )

    -- Bar Value
    if bDrawValue then
        surface.SetFont( "PRP.UI.Bar.Label" )
        surface.SetTextColor( 255, 255, 255, 150 )
        surface.SetTextPos( iBarX + iBarWidth + 10, iIconY + ( iIconHeight - 20 ) / 2 )
        surface.DrawText( math.floor( fnPercent() * 100 ) )
    end
end

hook.Add( "HUDPaint", "PRP.UI.HUDPaint", function()
    if PRP.Scene.Active then return end
    -- Drawn bottom to top

    -- PUI.Box( 0, 0, ScrW(), ScrH(), COLOR_WHITE )

    -- Health
    local iX = 15
    local iY = ScrH() - ( oMaterialHeart:Height() + 10 )
    PRP.UI.DrawBar( oMaterialHeart, iX, iY, fnHealthPercentSmoothed, Color( 255, 255, 255, 16 ) )

    -- Armor
    if LocalPlayer():Armor() > 0 then
        iY = iY - ( oMaterialHeart:Height() + 10 )
        PRP.UI.DrawBar( oMaterialHeart, iX, iY, fnArmorPercentSmoothed )
    end

    -- Recovery Timer
    local iRecoveryTime = LocalPlayer():GetLocalVar( "recoveryTimeEnd", false )
    if iRecoveryTime then
        local iRecoveryTimeRemaining = math.max( iRecoveryTime - CurTime(), 0 )

        iY = iY - ( oMaterialHeart:Height() + 10 )
        PRP.UI.DrawTimer( iX, iY, "RECOVERING", iRecoveryTimeRemaining )
    end


    -- Palomino Watermark
    surface.SetFont( "PRP.UI.Watermark.Header" )
    surface.SetTextPos( 15, 15 )
    surface.SetTextColor( 255, 255, 255, 32 )
    surface.DrawText( "PALOMINO.GG" )
    local iHeaderWidth, iHeaderHeight = surface.GetTextSize( "PALOMINO.GG" )

    surface.SetFont( "PRP.UI.Watermark.Subtext" )
    surface.SetDrawColor( 255, 255, 255, 32 )
    surface.SetTextPos( 15, 15 + iHeaderHeight )
    surface.DrawText( string.upper( Schema.version ) )

    -- @TODO: Put this in its own module/file thing
    -- Q Spawnmenu Hint

    -- surface.SetFont( "PRP.UI.Hint.Label" )

    -- local sHintText = "SPAWNMENU"
    -- local iHintLabelWidth, iHintLabelHeight = surface.GetTextSize( sHintText )

    -- local iHintX = ScrW() - iHintLabelWidth - 20

    -- surface.SetTextColor( 255, 255, 255, 16 )
    -- surface.SetTextPos( iHintX, ScrH() - 20 - 15 - ((36-20)/2) )
    -- surface.DrawText( sHintText )

    -- surface.SetMaterial( Material( "prp/ui/temp/key36_q.png" ) )
    -- surface.SetDrawColor( 255, 255, 255, 64 )
    -- surface.DrawTexturedRect( iHintX - 36 - 10, ScrH() - 36 - 15, 36, 36 )

    -- if true then return end

	-- local iXPadding = 16
	-- local iYPadding = 20

	-- local iXGap = 16

	-- local iHealth = LocalPlayer():Health()
	-- local iMaxHealth = LocalPlayer():GetMaxHealth()
	-- local iHealthPercentage = iHealth / iMaxHealth

	-- -- Heart Icon
	-- local iHeartWidth = oMaterialHeart:Width()
	-- local iHeartHeight = oMaterialHeart:Height()
	-- local iHeartX = iXPadding
	-- local iHeartY = ScrH() - ( iHeartHeight / 2 ) - iYPadding

	-- surface.SetMaterial( oMaterialHeart )
	-- surface.SetDrawColor( 255, 255, 255, 32 )
	-- surface.DrawTexturedRect( iHeartX, iHeartY, iHeartWidth, iHeartHeight )

	-- -- Healthbar background
	-- local iHealthbarWidth = 350
	-- local iHealthbarHeight = 5
	-- local iHealthbarX = iHeartX + iHeartWidth + iXGap
	-- local iHealthbarY = ScrH() - ( iHealthbarHeight / 2 ) - iYPadding

    -- -- Give a touch of contrast in dark areas
    -- surface.SetDrawColor( 255, 255, 255, 1 )
    -- surface.DrawRect( iHealthbarX, iHealthbarY, iHealthbarWidth, iHealthbarHeight )

    -- -- Overlay background
	-- render.OverrideBlend(
	-- 	true,
	-- 	BLEND_DST_COLOR,
	-- 	BLEND_SRC_COLOR,
	-- 	BLENDFUNC_ADD
	-- )

	-- surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.DrawRect( iHealthbarX, iHealthbarY, iHealthbarWidth, iHealthbarHeight )

	-- render.OverrideBlend( false )

	-- -- Healthbar Progress

	-- -- Healthbar Progress - Gradient
	-- surface.SetMaterial( oGradientLeft )
	-- surface.SetDrawColor( 255, 255, 255, 32 )
	-- surface.DrawTexturedRectUV(
	-- 	iHealthbarX,
	-- 	iHealthbarY,
	-- 	iHealthbarWidth * iHealthPercentage,
	-- 	iHealthbarHeight,
	-- 	-- u1
    --     1 - iHealthPercentage,
    --     -- v1
	-- 	0,
    --     -- u2
	-- 	1,
    --     -- v2
	-- 	1
	-- )

	-- -- Healthbar Progress - Pill
	-- local iHealthbarPillWidth = oHealthbarPill:Width()
	-- local iHealthbarPillHeight = oHealthbarPill:Height()

	-- local iHealthbarPillX = iHealthbarX + iHealthbarWidth * iHealthPercentage - iHealthbarPillWidth / 2
	-- local iHealthbarPillY = iHealthbarY

	-- surface.SetMaterial( oHealthbarPill )
	-- surface.SetDrawColor( 255, 255, 255, 255 )
	-- surface.DrawTexturedRect( iHealthbarPillX, iHealthbarPillY, iHealthbarPillWidth, iHealthbarPillHeight )
end )