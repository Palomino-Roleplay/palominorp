PRP.UI = PRP.UI or {}

local PANEL = {}

local MAT_STATIC = Material("prp/ui/textures/static.png", "noclamp")
local MAT_LOGO = Material("prp/ui/mainmenu/logo-pre-alpha.png")
local MAT_BG = Material("prp/ui/mainmenu/bg.png")

PRP.UI.IntroSound = PRP.UI.IntroSound or nil
function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:SetTitle( "" )
    self:SetDraggable( false )
    local pSelect = vgui.Create( "PRP.Select", self )
    pSelect:SetSize( 300 * PRP.UI.ScaleFactor, 2 * ScrH() / 3 )
    pSelect:SetPos( 275 * PRP.UI.ScaleFactor, 2 * ScrH() / 3 )

    gui.EnableScreenClicker( true )

    self.m_iOpenTime = CurTime()

    pSelect:AddButton( "DISCORD", function()
        gui.OpenURL( "https://discord.gg/ETNem7McnD" )
    end )

    pSelect:AddButton( "NEW CHARACTER", function()
        if #ix.characters > 3 then
            Derma_Message( "You have reached the maximum amount of characters.", "Error", "OK" )
            return
        end

        net.Start("PRP.Playtesting.NewCharacter")
        net.SendToServer()

        self:Remove()
    end )

    pSelect:AddButton( "CONTINUE", function( pButton )
        pButton:OpenSubMenu( function( pSubMenu )
            for i = 1, #ix.characters do
                local iID = ix.characters[i]
                local cCharacter = ix.char.loaded[i]

                if not cCharacter then continue end

                pSubMenu:AddButton( string.upper( cCharacter:GetName() ), function()
                    net.Start("ixCharacterChoose")
                        net.WriteUInt(cCharacter:GetID(), 32)
                    net.SendToServer()

                    self:Remove()
                end )
            end
        end )
        print("test")
    end )

    local function fnBackgroundEffects()
        if not self then
            hook.Remove( "RenderScreenspaceEffects", "PRP.UI.MainMenu.RenderScreenspaceEffects" )
            return
        end

        local tTable = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 1.4,
            ["$pp_colour_contrast"] = 0.35,
            ["$pp_colour_colour"] = 0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        DrawColorModify( tTable )
    end
    hook.Add( "RenderScreenspaceEffects", "PRP.UI.MainMenu.RenderScreenspaceEffects", fnBackgroundEffects )

    if PRP.Scene.Active then
        PRP.Scene.Active:Stop()
        PRP.Scene.Active = nil
    end

    local oCameraLayer
    PRP.Scene.Active, oCameraLayer = PRP.Scene.Create( {}, "CameraConstant" )
    PRP.Scene.Active:SetDuration( 120 )
    oCameraLayer:AddToPath( Vector( 313, -1182, 730 ), Angle( 12, 91, 0 ) )
    oCameraLayer:AddToPath( Vector( 354, 6126, 609 ), Angle( 10, -1, 0 ) )
    oCameraLayer:AddToPath( Vector( 2392, 6221, 669 ), Angle( 6, 91, 0 ) )
    oCameraLayer:AddToPath( Vector( 2268, 9340, 334 ), Angle( 3, 179, 0 ) )

    -- for iIndex, tData in ipairs( PRP.Scene.ParamTest ) do
    --     oCameraLayer:AddToPath( tData[ 1 ], tData[ 2 ], tData.controlPoints )
    -- end

    PRP.Scene.Active:Start()
end

function PANEL:OnRemove()
    gui.EnableScreenClicker( false )
    hook.Remove( "RenderScreenspaceEffects", "PRP.UI.MainMenu.RenderScreenspaceEffects" )
    PRP.UI.IntroSound:FadeOut( 5 )

    if PRP.Scene.Active then
        PRP.Scene.Active:Stop()
        PRP.Scene.Active = nil
    end
end

function PANEL:Paint()
    -- @TODO: Find out why screenclicker isn't enabled on first open, even if we put it on initialize.
    if not vgui.CursorVisible() then
        gui.EnableScreenClicker( true )
    end

    ix.util.DrawBlur( self, 8 )

    PUI.StartOverlay()
        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( MAT_BG )
        surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
    PUI.EndOverlay()

    surface.SetDrawColor( 255, 255, 255, 1 )
    surface.SetMaterial( MAT_STATIC )
    -- Repeat original 512x512 texture over the screen
    -- @TODO: Maybe make it 1024x1024?
    surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, ScrW() / 512, ScrH() / 512 )

    surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( MAT_LOGO )
    surface.DrawTexturedRect( 275, ( ScrH() - 82 ) / 2, MAT_LOGO:Width() * PRP.UI.ScaleFactor, MAT_LOGO:Height() * PRP.UI.ScaleFactor )

    local iTimePerc = ( CurTime() - self.m_iOpenTime ) / 2

    if iTimePerc < 1 then
        local iOverlayPerc = math.Clamp( math.ease.OutExpo( iTimePerc ), 0, 1 )
        PUI.StartOverlay()
            local iValue = 255 - 64 * iOverlayPerc
            surface.SetDrawColor( iValue, iValue, iValue )
            surface.DrawRect( 0, 0, ScrW(), ScrH() )
            surface.DrawRect( 0, 0, ScrW(), ScrH() )
            surface.DrawRect( 0, 0, ScrW(), ScrH() )
            surface.DrawRect( 0, 0, ScrW(), ScrH() )
        PUI.EndOverlay()
    end
end

concommand.Add( "prp_mainmenu", function()
    if PRP.UI.MainMenu then
        PRP.UI.MainMenu:Remove()
        PRP.UI.MainMenu = nil
    end

    PRP.UI.MainMenu = vgui.Create( "PRP.MainMenu" )
end )

vgui.Register( "PRP.MainMenu", PANEL, "DFrame" )





PANEL = {}

surface.CreateFont( "PRP.Intro.Default", {
    font = "Inter",
    size = 16,
    weight = 500,
    antialias = true
} )

surface.CreateFont( "PRP.Intro.Present", {
    font = "Inter",
    size = 24,
    weight = 600,
    antialias = true
} )

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )

    self:ShowCloseButton( false )
    self:SetDraggable( false )

    self.m_bStarted = false
    self.m_iStartTime = 0

    -- Load the disclaimer image
    self.disclaimerMat = Material("prp/ui/temp/intro-disclaimer.png")

    self.debugPercText = {}
    self.debugPercTextPanel = vgui.Create( "DPanel", self )
    self.debugPercTextPanel:SetSize( 200, 50 )
    self.debugPercTextPanel:SetPos( 0, 0 )
    self.debugPercTextPanel.Paint = function( _, iW, iH )
        -- surface.SetFont( "DebugFixed" )

        -- local iY = 0
        -- for sLabel, sText in pairs( self.debugPercText or {} ) do
        --     iY = iY + 16

        --     surface.SetTextColor( 255, 255, 255 )
        --     surface.SetTextPos( 5, iY )
        --     surface.DrawText( sLabel .. ": " .. sText )
        -- end
    end
end

function PANEL:Paint( iW, iH )
    surface.SetDrawColor( 0, 0, 0 )
    surface.DrawRect( 0, 0, iW, iH )

    if not self.m_bStarted then
        surface.SetFont( "PRP.Intro.Title" )
        local iTextW, iTextH = surface.GetTextSize( "Press any key to continue..." )

        surface.SetTextColor( 255, 255, 255 )
        surface.SetTextPos( iW / 2 - iTextW / 2, iH / 2 - iTextH / 2 )
        surface.DrawText( "Press any key to continue..." )
        return
    end

    local curTime = CurTime() - self.m_iStartTime

    -- Disclaimer image animation (1.5s to 4.5s fade in, show until 11.5s, fade out until 13.5s)
    if curTime >= 1.5 and curTime <= 13.5 then
        local imageW, imageH = self.disclaimerMat:Width(), self.disclaimerMat:Height()  -- Adjust size as needed
        local x, y = iW/2 - imageW/2, iH/2 - imageH/2

        local alpha = 0
        local blurAmount = 0

        if curTime <= 4.5 then
            -- Fade in and unblur
            local progress = (curTime - 1.5) / 3
            alpha = math.Clamp(progress * 255, 0, 255)
            blurAmount = math.Clamp(10 * (1 - progress), 0, 10)
        elseif curTime <= 11.5 then
            -- Full display
            alpha = 255
            blurAmount = 0
        else
            -- Fade out
            local progress = (curTime - 11.5) / 2
            alpha = math.Clamp(255 * (1 - progress), 0, 255)
        end

        self.debugPercText = {
            ["1-Alpha"] = math.Round( alpha, 2 ),
            ["1-Blur"] = math.Round( blurAmount, 2 )
        }

        surface.SetDrawColor(255, 255, 255, alpha)
        surface.SetMaterial(self.disclaimerMat)
        surface.DrawTexturedRect(x, y, imageW, imageH)

        if blurAmount > 0 then
            -- ix.util.DrawBlurAt(x, y, imageW, imageH, blurAmount, 3, alpha)
        end
    end

    -- "sil & Knight Present" text animation (14.5s to 18s fade in)
    if curTime >= 14.5 and curTime <= 23.25 then
        surface.SetFont("PRP.Intro.Present")
        local text = "sil & Knight Present"
        local textW, textH = surface.GetTextSize(text)
        local x, y = iW/2 - textW/2, iH/2 - textH/2

        local alpha = 0
        local blurAmount = 0

        if curTime <= 18 then
            -- Fade in and unblur
            local progress = (curTime - 14.5) / 3.5
            alpha = math.Clamp(progress * 255, 0, 255)
            blurAmount = math.Clamp(10 * (1 - progress), 0, 10)
        elseif curTime <= 21.25 then
            -- Full display
            alpha = 255
            blurAmount = 0
        elseif curTime <= 23.25 then
            -- Fade out
            local progress = (curTime - 21.25) / 2
            alpha = math.Clamp(255 * (1 - progress), 0, 255)
        end

        self.debugPercText = {
            ["2-Alpha"] = math.Round( alpha, 2 ),
            ["2-Blur"] = math.Round( blurAmount, 2 )
        }

        surface.SetTextColor(255, 255, 255, alpha)
        surface.SetTextPos(x, y)
        surface.DrawText(text)

        if blurAmount > 0 then
            -- ix.util.DrawBlurAt(x, y, textW, textH, blurAmount, 3, alpha)
        end
    end
end

function PANEL:Think()
    if not self.m_bStarted then
        local bAnyKeyPressed = false
        for key = KEY_FIRST, KEY_LAST do
            if input.IsKeyDown(key) then
                bAnyKeyPressed = true
                break
            end
        end

        if bAnyKeyPressed then
            self.m_bStarted = true
            self.m_iStartTime = CurTime()

            if not PRP.UI.IntroSound then
                PRP.UI.IntroSound = CreateSound( game.GetWorld(), "palomino/palomino-intro.mp3" )
                PRP.UI.IntroSound:SetSoundLevel( 0 )
            end

            PRP.UI.IntroSound:Play()
        else
            return
        end
    end

    -- Check if it's time to remove the panel and run the command
    if self.m_bStarted and (CurTime() - self.m_iStartTime) >= 23.25 then
        RunConsoleCommand("prp_mainmenu")
        self:Remove()
    end
end

concommand.Add( "prp_intro", function()
    if PRP.UI.Intro then
        PRP.UI.Intro:Remove()
        PRP.UI.Intro = nil
    else
        PRP.UI.Intro = vgui.Create( "PRP.Intro" )
    end
end )

vgui.Register( "PRP.Intro", PANEL, "DFrame" )