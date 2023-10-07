PRP.UI = PRP.UI or {}

local oHeartNoAlphatest = Material( "prp/icons/hud/heart.png" )

local oGradientLeft = Material( "prp/icons/hud/gradient_left.png" )

local function fnHealthPercentSmoothed()
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
    antialias = true,
    shadow = true
})

surface.CreateFont( "PRP.UI.Timer.Time", {
    font = "Inter",
    size = 24,
    weight = 700,
    antialias = true,
    shadow = true
} )

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
function PRP.UI.DrawBar( oMaterial, iX, iY, fnPercent )
    local iXPadding = 16
	local iYPadding = 20

    local iXGap = 16

    local iIconWidth = oMaterial:Width()
    local iIconHeight = oMaterial:Height()

    local iIconX = iX
    local iIconY = iY

    surface.SetMaterial( oMaterial )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawTexturedRect( iIconX, iIconY, iIconWidth, iIconHeight )

    -- Bar background

    local iBarWidth = 420
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
    surface.SetDrawColor( 255, 255, 255, 32 )
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
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawTexturedRect( iBarPillX, iBarPillY, iBarPillWidth, iBarPillHeight )
end

hook.Add( "HUDPaint", "PRP.UI.HUDPaint", function()
    -- Drawn bottom to top

    -- Health
    local iY = ScrH() - ( oHeartNoAlphatest:Height() + 10 )
    PRP.UI.DrawBar( oHeartNoAlphatest, 15, ScrH() - ( oHeartNoAlphatest:Height() + 10 ), fnHealthPercentSmoothed )

    -- Armor
    if LocalPlayer():Armor() > 0 then
        iY = iY - ( oHeartNoAlphatest:Height() + 10 )
        PRP.UI.DrawBar( oHeartNoAlphatest, 15, iY, fnArmorPercentSmoothed )
    end

    -- Recovery Timer
    local iRecoveryTime = LocalPlayer():GetLocalVar( "recoveryTimeEnd", false )
    if iRecoveryTime then
        local iRecoveryTimeRemaining = math.max( iRecoveryTime - CurTime(), 0 )

        iY = iY - ( oHeartNoAlphatest:Height() + 10 )
        PRP.UI.DrawTimer( 15, iY, "RECOVERING", iRecoveryTimeRemaining )
    end

    -- if true then return end

	-- local iXPadding = 16
	-- local iYPadding = 20

	-- local iXGap = 16

	-- local iHealth = LocalPlayer():Health()
	-- local iMaxHealth = LocalPlayer():GetMaxHealth()
	-- local iHealthPercentage = iHealth / iMaxHealth

	-- -- Heart Icon
	-- local iHeartWidth = oHeartNoAlphatest:Width()
	-- local iHeartHeight = oHeartNoAlphatest:Height()
	-- local iHeartX = iXPadding
	-- local iHeartY = ScrH() - ( iHeartHeight / 2 ) - iYPadding

	-- surface.SetMaterial( oHeartNoAlphatest )
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