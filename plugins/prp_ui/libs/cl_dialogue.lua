PUI = PUI or {}
PUI.Dialogue = PUI.Dialogue or {}

PUI.Dialogue.Active = false

local function fnDefaultAbortCondition()
    return ( not PUI.Dialogue.Active ) 
        or ( not IsValid( PUI.Dialogue.Active.eEntity ) )
        -- or ( not PUI.Dialogue.Active.eEntity:IsAlive() )
        or ( not LocalPlayer():IsValid() )
        or ( not LocalPlayer():Alive() )
        -- or ( not LocalPlayer():KeyDown( IN_USE ) ) -- Handled PUI.Dialogue.Select()
        or ( PUI.Dialogue.Active.eEntity:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 16000 )
        -- or ( PUI.Dialogue.Active.eEntity:GetForward():Dot( LocalPlayer():GetForward() ) < 0.5 )
end

function PUI.Dialogue.Close()
    PUI.Dialogue.Active = false
    hook.Remove( "PostDrawTranslucentRenderables", "PUI.Dialogue.Draw" )

    Print( "PUI Dialogue closed." )
end

function PUI.Dialogue.Select()
    PUI.Dialogue.Close()
    iTempSelectedOption = -1

    Print( "PUI Dialogue selected." )
end

local iTempSelectedOption = 0 -- @TODO: Don't do it like this please.
local iTempOpenTime = 0
local iConfigFadeTime = 0.8
local bTempAnyOverlaps = false
-- local tOptions = {"'i wanna be a cop'", "'id like to turn myself in'", "'id like to pay my ticket'"}

local oGlowMaterial = Material( "prp/ui/temp/glow.png" )
local function fnDrawDialogue( bDrawingDepth, bDrawingSkybox )
    if bDrawingSkybox then return end

    if not PUI.Dialogue.Active then
        PUI.Dialogue.Close()
        return
    end

    if PUI.Dialogue.Active.fnAbortCondition() then
        PUI.Dialogue.Close()
        return
    end

    -- Option selected
    if not LocalPlayer():KeyDown( IN_USE ) then
        PUI.Dialogue.Select()

        iTempOpenTime = 0

        -- if iTempSelectedOption != -1 then
        --     surface.PlaySound( "prp/ui/click.wav" )

        --     if iTempSelectedOption == 1 then
        --         PUI.Dialogue.Active.eEntity:SetTextLine( "how about you hit the gym first?" )

        --         tOptions = {"'low blow man...'", "'go fuck yourself.'", "'ugh, fine.'"}
        --     elseif iTempSelectedOption == 2 then
        --         PUI.Dialogue.Active.eEntity:SetTextLine( "fuck off you little bitch." )

        --         tOptions = {1, 2, 3, 4, "a lot"}
        --     elseif iTempSelectedOption == 3 then
        --         PUI.Dialogue.Active.eEntity:SetTextLine( "palomino pd, how can i help you?" )
        --         tOptions = {"'i wanna be a cop'", "'id like to turn myself in'", "'id like to pay my ticket'"}
        --     end

        --     iTempSelectedOption = -1
        -- end
        return
    end

    if iTempOpenTime == 0 then
        iTempOpenTime = CurTime()
    end

    local iTempFadePerc = math.min( CurTime() - iTempOpenTime, iConfigFadeTime ) / iConfigFadeTime
    iTempFadePerc = math.ease.OutElastic( iTempFadePerc )

    -- Alpha fade
    surface.SetAlphaMultiplier( iTempFadePerc )

    -- Stencil magic.
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	render.SetStencilEnable( true )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
	render.SetStencilReferenceValue( 0x1C )
	render.SetStencilWriteMask( 0x55 )

    PUI.Dialogue.Active.eEntity:DrawModel()

	render.SetStencilTestMask( 0xF3 )
	render.SetStencilReferenceValue( 0x10 )
    render.SetStencilCompareFunction( STENCIL_GREATER )

    local vPos = PUI.Dialogue.Active.eEntity:GetPos() + PUI.Dialogue.Active.eEntity:OBBCenter()
    local vHeadPos = vPos + Vector( 0, 0, 32 )
    local iScaleFactor = 1 / PUI.Dialogue.Active.eEntity:GetPos():Distance( LocalPlayer():GetPos() )

    local iInitialWidth = 40000
    local iInitialHeight = 75000

    local tScreenPos = vPos:ToScreen()
    local iX = tScreenPos.x - ( iInitialWidth / 2 * iScaleFactor )
    local iY = tScreenPos.y - ( iInitialHeight / 2 * iScaleFactor )

    local tHeadScreenPos = vHeadPos:ToScreen()

    local iWidth = iInitialWidth * iScaleFactor
    local iHeight = iInitialHeight * iScaleFactor

    local iSelectX = tScreenPos.x + ( 10000 * iScaleFactor )
    local iSelectY = tScreenPos.y - ( 20000 * iScaleFactor * ( 0.9 + iTempFadePerc / 10 ) )

    cam.Start2D()
        surface.SetDrawColor( 255, 255, 255, 64 )
        surface.DrawLine( tHeadScreenPos.x, tHeadScreenPos.y, iSelectX, iSelectY )

        render.OverrideDepthEnable( true, false )

        local oGlowColor = PUI.Dialogue.Active.eEntity:GetDialogueColor() or Color( 255, 255, 255, 32 )
        surface.SetMaterial(oGlowMaterial)
        surface.SetDrawColor(oGlowColor.r, oGlowColor.g, oGlowColor.b, oGlowColor.a)

        surface.DrawTexturedRect(iX, iY, iWidth, iHeight) -- Centered on the player's bounding box

        render.OverrideDepthEnable( false )
    cam.End2D()

    render.SetStencilCompareFunction( STENCIL_GREATEREQUAL )

    cam.Start2D()
        local iCursorX, iCursorY = ScrW() / 2, ScrH() / 2
        local iOptionWidth = 250
        local iOptionHeight = 40

        local tDialogueOptions = PUI.Dialogue.Active.tOptions or {}

        -- Soft gradient background behind the options
        surface.SetMaterial( Material( "gui/gradient" ) )
        surface.SetDrawColor( 32, 36, 42, 160 )
        surface.DrawTexturedRect( iSelectX + 2, iSelectY, iOptionWidth, iOptionHeight * #tDialogueOptions )

        -- Draw the options & see if we're hovering over any of them
        local bAnyOverlaps = false
        for i, sOption in ipairs(tDialogueOptions) do
            local bOverlapsX = iSelectX < iCursorX and iSelectX + iOptionWidth > iCursorX
            local bOverlapsY = iSelectY < iCursorY and iSelectY + iOptionHeight > iCursorY
            local bHovered = bOverlapsX and bOverlapsY

            if bHovered then
                if i != iTempSelectedOption then
                    surface.PlaySound( "prp/ui/hover.wav" )
                end

                bAnyOverlaps = true
                bTempAnyOverlaps = true

                iTempSelectedOption = i

                surface.SetDrawColor( PUI.GREEN:Unpack() )
                surface.DrawRect( iSelectX, iSelectY, 2, 40 )

                PUI.StartOverlay()
                    surface.SetMaterial( Material( "prp/ui/temp/gradient_overlay2_left.png" ) )
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.DrawRect( iSelectX + 2, iSelectY, iOptionWidth, iOptionHeight )
                PUI.EndOverlay()

                surface.SetMaterial( Material( "gui/gradient" ) )
                surface.SetDrawColor( ColorAlpha( PUI.GREEN, 64 ):Unpack() )
                surface.DrawTexturedRect( iSelectX + 2, iSelectY, iOptionWidth, iOptionHeight )

                surface.SetTextColor( 255, 255, 255, 255 )
                surface.SetFont( "PRP.UI.Interaction.Option" )
                surface.SetTextPos( iSelectX + 20, iSelectY + ( ( iOptionHeight / 2 ) / 2 ) )
                surface.DrawText( sOption )
            else
                surface.SetDrawColor( 255, 255, 255, 64 )
                surface.DrawRect( iSelectX, iSelectY, 2, iOptionHeight )

                surface.SetTextColor( 255, 255, 255, 64 )
                surface.SetFont( "PRP.UI.Interaction.Option" )
                surface.SetTextPos( iSelectX + 20, iSelectY + ( ( iOptionHeight / 2 ) / 2 ) )
                surface.DrawText( sOption )
            end

            iSelectY = iSelectY + iOptionHeight
        end

        -- A little gradient on the bottom to hold the box up in the air
        surface.SetMaterial( Material( "gui/gradient" ) )
        surface.SetDrawColor( 255, 255, 255, 64 )
        if iTempSelectedOption == #tDialogueOptions then
            surface.SetDrawColor( PUI.GREEN:Unpack() )
        end
        surface.DrawTexturedRect( iSelectX, iSelectY, iOptionWidth, 2 )

        if not bTempAnyOverlaps then
            iTempSelectedOption = -1
        end

        if not bAnyOverlaps and bTempAnyOverlaps then
            bTempAnyOverlaps = false
        end
    cam.End2D()

	-- Let everything render normally again
	render.SetStencilEnable( false )
    surface.SetAlphaMultiplier( 1 )
end

function PUI.Dialogue.New( eEntity, tOptions, fnAbortCondition )
    Print( "PUI Dialogue opened." )

    fnAbortCondition = fnAbortCondition or fnDefaultAbortCondition

    PUI.Dialogue.Active = {
        eEntity = eEntity,
        tOptions = tOptions,
        fnAbortCondition = fnAbortCondition
    }

    hook.Add( "PostDrawTranslucentRenderables", "PUI.Dialogue.Draw", fnDrawDialogue )
end

concommand.Add( "prp_dev_selectionmenu", function()
    local eEntity = LocalPlayer():GetEyeTrace().Entity

    if not IsValid( eEntity ) then return end
    if eEntity:EntIndex() == 0 then return end

    PUI.Dialogue.New( eEntity, {
        "kiss",
        "smooch",
        "hug",
    } )
end )