-- @TODO: REMOVE THIS ENTIRE FILE
print("test")

local r = {
    Material( "prp/waves/r1.png" ),
    Material( "prp/waves/r2.png" ),
    Material( "prp/waves/r3.png" ),
    Material( "prp/waves/r4.png" ),
    Material( "prp/waves/r5.png" ),
    Material( "prp/waves/r6.png" ),
    Material( "prp/waves/r7.png" ),
    Material( "prp/waves/r8.png" ),
    Material( "prp/waves/r9.png" ),
}

local mInv = Material( "prp/Inventory.png" )
local matBlurScreen = Material( "pp/blurscreen" )

-- hook.Add( "HUDPaint", "Test test", )
hook.Remove( "HUDPaint", "Test test" )

local function blurScreen()
    surface.SetMaterial( matBlurScreen )
    surface.SetDrawColor( 255, 255, 255, 255 )

    for i=0.33, 1, 0.33 do
        matBlurScreen:SetFloat( "$blur", 5 * i * easedFrac )
        matBlurScreen:Recompute()
        if ( render ) then render.UpdateScreenEffectTexture() end -- Todo: Make this available to menu Lua
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
    end
end

local function drawInventory()
    blurScreen()

    for i = 1, 9 do
        surface.SetMaterial( r[i] )
        surface.SetDrawColor( 255, 255, 255, 255 * 0.15 * easedFrac )

        local curtime = CurTime() / 5 + ( math.sin( i ) * i )

        local eq = ( math.sin( curtime ) ^ 5 + math.cos( curtime ) )
        local x = ( 1920 - 2580 ) / 2  + ( 200 * eq )
        -- print(i, x)
        surface.DrawTexturedRect( x, 0, 2580, ScrH() )
    end

    surface.SetMaterial( mInv )
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

    -- surface.SetFont( "prp_inv" )
    -- surface.SetTextColor( 255, 255, 255, 255 )
    -- surface.SetTextPos( 368, 250 )
    -- surface.DrawText( "BACKPACK" )
end




local function ssInventory()
    -- if not PRP_TEST_MENU then return end

    local tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.3 * easedFrac,
        ["$pp_colour_contrast"] = 1 - (0.3 * easedFrac),
        ["$pp_colour_colour"] = 1 * (1 - easedFrac),
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    -- print("AYO???")
    -- print(easedFrac)

    DrawColorModify( tab )
end
hook.Add("RenderScreenspaceEffects", "PostProcessingExample", ssInventory )


local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
    ["CHudCrosshair"] = true,
}

local function hideHUDInventory( name )
    if not PRP_TEST_MENU then return end

	if ( hide[ name ] ) then
		return false
	end

end
hook.Add( "HUDShouldDraw", "HideHUDInventory", hideHUDInventory )

surface.CreateFont( "prp_inv", {
    font = "Futura PT Heavy",
    size = 60,
    weight = 100,
    antialias = true,
    shadow = false,
} )


local matDevSplash = Material( "prp/dev_preview_splash.png" )
local matDevButton = Material( "prp/dev_preview_accept.png" )

concommand.Add( "prp_devpreview", function()
    local pDevPreview = vgui.Create( "DPanel" )
    pDevPreview:SetPos( 0, 0 )
    pDevPreview:SetSize( ScrW(), ScrH() )
    pDevPreview:MakePopup()
    pDevPreview.Paint = function()
        -- blurScreen()
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawRect( 0, 0, ScrW(), ScrH() )

        surface.SetMaterial( matDevSplash )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
    end

    local pDevPreviewButton = vgui.Create( "DButton", pDevPreview )
    pDevPreviewButton:SetPos( ScrW() / 2 - ( 368 / 2 ), ScrH() - 305 )
    pDevPreviewButton:SetSize( 368, 73 )
    pDevPreviewButton:SetText( "" )
    pDevPreviewButton.hoverSoundPlayed = false
    pDevPreviewButton.Paint = function()
        local bIsHovered = pDevPreviewButton:IsHovered()
        local bIsDown = pDevPreviewButton:IsDown()

        if bIsHovered and not pDevPreviewButton.hoverSoundPlayed then
            pDevPreviewButton.hoverSoundPlayed = true
            surface.PlaySound( "prp/ui/hover.wav" )
        elseif not bIsHovered then
            pDevPreviewButton.hoverSoundPlayed = false
        end

        local iAlphaTarget = bIsDown and 225 or ( bIsHovered and 255 or 64 )
        local iCurrentAlpha = pDevPreviewButton.iCurrentAlpha or 215

        pDevPreviewButton.iCurrentAlpha = Lerp( RealFrameTime() * 30, iCurrentAlpha, iAlphaTarget )

        surface.SetMaterial( matDevButton )
        surface.SetDrawColor( 255, 255, 255, pDevPreviewButton.iCurrentAlpha )
        surface.DrawTexturedRect( 0, 0, pDevPreviewButton:GetWide(), pDevPreviewButton:GetTall() )
    end
    pDevPreviewButton.DoClick = function()
        surface.PlaySound( "prp/ui/click.wav" )
        pDevPreview:Remove()
        easedFrac = 0

        RunConsoleCommand( "prp_intro_start" )
    end

    easedFrac = 1
end )

local matInvBG = Material( "prp/InventoryBG.png" )
local matInvL = Material( "prp/InventoryL.png" )

PRP_TEST_MENU = PRP_TEST_MENU or false
iCurrentAlpha = 0
iAlphaTarget = 0
easedFrac = 0
concommand.Add( "prp_testmenu", function()
    iAlphaTarget = PRP_TEST_MENU and 255 or 0
    -- if iCurrentAlpha ~= iAlphaTarget then return end

    if not PRP_TEST_MENU then
        PRP_TEST_MENU = vgui.Create( "DPanel" )

        iAlphaTarget = 255
    else
        iAlphaTarget = 0

        timer.Simple( 0.15, function()
            PRP_TEST_MENU:Remove()
            PRP_TEST_MENU = false

            hook.Remove( "PreDrawHalos", "toiasjdoisjad" )
        end )

        return
    end

    PRP_TEST_MENU:SetSize( ScrW(), ScrH() )
    PRP_TEST_MENU.Paint = function()
        drawInventory()
    end

    local frac = iAlphaTarget / 255

    local wow = vgui.Create( "DModelPanel", PRP_TEST_MENU )
    wow:SetPos( 1115 - 70, 217 - 90 )
    wow:SetSize( 267 + 140, 766 + 180 )
    wow:SetModel( LocalPlayer():GetModel() )
    wow:SetFOV( 6 )
    wow:SetAmbientLight( Color( 0, 0, 0 ) )

    -- hook.Add( "PreDrawHalos", "toiasjdoisjad", function()
    --     print( wow.Entity )
    --     halo.Add( { wow.Entity }, Color( 255, 0, 0, 255 * easedFrac ), 1, 1, 1, true, true )
    -- end )

    function wow:LayoutEntity( eEntity )
        if ( self.bAnimated ) then
            self:RunAnimation()
        end

        return
    end
    function wow:PaintOver( w, h )
        -- surface.SetDrawColor( 255, 255, 255, 255 )
        -- surface.DrawOutlinedRect( 0, 0, w, h )
    end
    function wow:DrawModel()
        render.SetModelLighting(0, easedFrac, easedFrac, easedFrac)
        -- self:LayoutEntity( self.Entity )

        render.SetStencilWriteMask( 0xFF )
        render.SetStencilTestMask( 0xFF )
        render.SetStencilReferenceValue( 0 )
        render.SetStencilCompareFunction( STENCIL_ALWAYS )
        render.SetStencilPassOperation( STENCIL_KEEP )
        render.SetStencilFailOperation( STENCIL_KEEP )
        render.SetStencilZFailOperation( STENCIL_KEEP )
        render.ClearStencil()

        -- render.SetBlend( easedFrac )

        self.Entity:DrawModel()

        render.SetStencilEnable(true)
            -- Force everything to fail
            render.SetStencilCompareFunction( STENCIL_NEVER )
            -- Save all the things we don't draw
            render.SetStencilFailOperation( STENCIL_REPLACE )

            -- Set the reference value to 00011100
            render.SetStencilReferenceValue( 0x1C )
            -- Set the write mask to 01010101
            -- Any writes to the stencil buffer will be bitwise ANDed with this mask.
            -- With our current reference value, the result will be 00010100.
            render.SetStencilWriteMask( 0x55 )

            self.Entity:DrawModel()

            -- Set the test mask to 11110011.
            -- Any time a pixel is read out of the stencil buffer it will be bitwise ANDed with this mask.
            render.SetStencilTestMask( 0xF3 )
            -- Set the reference value to 00011100 & 01010101 & 11110011
            render.SetStencilReferenceValue( 0x10 )
            -- Pass if the masked buffer value matches the unmasked reference value
            render.SetStencilCompareFunction( STENCIL_EQUAL )

            cam.Start2D()
                -- render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_SRC_ALPHA, BLENDFUNC_ADD )
                
                surface.SetMaterial( matInvL )
                render.OverrideBlend( true, BLEND_DST_COLOR, BLEND_DST_ALPHA, BLENDFUNC_ADD, BLEND_SRC_COLOR, BLEND_DST_ALPHA, BLENDFUNC_ADD )
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( 0, 0, ScrW(), ScrH())
                
                -- surface.SetMaterial( matInvBG )
                -- render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_ZERO, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_ZERO, BLENDFUNC_ADD )
                -- surface.SetDrawColor( 255, 255, 255, 255 )
                -- surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )

                -- surface.DrawRect( 0, 0, ScrW(), ScrH() )

                render.OverrideBlend( false )
            cam.End2D()

            -- Draw our entities
            -- render.ClearBuffersObeyStencil( 65, 65, 90, 255, false )

        render.SetStencilEnable(false)

        -- render.SetScissorRect(0, 0, 0, 0, false)
        -- render.SuppressEngineLighting(false)

        render.SetBlend( 1 )

        -- self.Entity:DrawModel()
    end


    function PRP_TEST_MENU:Think( this )
        if iCurrentAlpha ~= iAlphaTarget then
            iCurrentAlpha = Lerp( RealFrameTime() * 10, iCurrentAlpha, iAlphaTarget )
            frac = iCurrentAlpha / 255
            easedFrac = math.ease.InOutQuad( frac )

            -- wow:SetAlpha( iAlphaTarget == 255 and 255 or math.floor( easedFrac * 255 ) )
            PRP_TEST_MENU:SetAlpha( math.floor( easedFrac * 255 ) )
            -- wow:SetAlpha( 0 )

            -- print( "mouse pos:" )
            -- print( gui.ScreenToVector( gui.MousePos() ) )

            wow:SetDirectionalLight(BOX_TOP, (Color(71, 172, 255):ToVector() * frac):ToColor())
            wow:SetDirectionalLight(BOX_BACK, (Color(0, 0, 0):ToVector() * frac):ToColor())
            wow:SetDirectionalLight(BOX_LEFT, (Color(52, 124, 184):ToVector() * frac):ToColor())
            wow:SetDirectionalLight(BOX_BOTTOM, (Color(93, 57, 151):ToVector() * frac):ToColor())
            wow:SetDirectionalLight(BOX_RIGHT, (Color(44, 104, 71):ToVector() * frac):ToColor())
            wow:SetDirectionalLight(BOX_FRONT, (Color(255, 255, 255):ToVector() * frac):ToColor())
        end
    end

    -- Good ones:
    -- idle_all_01
    -- idle_all_02
    -- idle_all_angry
    -- idle_all_scared
    -- idle_all_cower
    -- pose_standing_01
    -- pose_standing_02
    -- pose_ducking_01
    -- pose_ducking_02

    -- Funny ones:
    -- pose_standing_03
    -- pose_standing_04
    -- death_01
    -- death_02
    -- death_03
    -- death_04

    local headpos = wow.Entity:GetBonePosition(wow.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    local spinepos = wow.Entity:GetBonePosition(wow.Entity:LookupBone("ValveBiped.Bip01_Spine"))
    wow:SetLookAt(spinepos-Vector(0, 0, 7))
    wow:SetCamPos(spinepos-Vector(-90 * 3, -50 * 3, 0))
    wow.Entity:SetEyeTarget( headpos + Vector( 16, 1, 0 ) )

    wow:SetAnimated( true )
    timer.Simple(0, function()
        wow.Entity:ResetSequence( wow.Entity:LookupSequence( "idle_all_01" ) )
    end )
end )

bIntroRun = bIntroRun or false
hook.Add( "OnCharacterMenuCreated", "PRP.TECH_DEMO.OnCharacterMenuCreated", function( panel )
    if bIntroRun then return end

    bIntroRun = true

    RunConsoleCommand( "prp_devpreview" )
    panel:Hide()
end )