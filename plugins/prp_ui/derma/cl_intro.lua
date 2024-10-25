PRP.UI = PRP.UI or {}

local PANEL = {}

local MAT_STATIC = Material("prp/ui/textures/static.png", "noclamp")
local MAT_LOGO = Material("prp/ui/mainmenu/logo-pre-alpha.png")
local MAT_BG = Material("prp/ui/mainmenu/bg.png")

PRP.UI.MainMenuIntroSound = PRP.UI.MainMenuIntroSound or nil
function PANEL:Init()
    if not PRP.UI.MainMenuIntroSound then
        PRP.UI.MainMenuIntroSound = CreateSound( game.GetWorld(), "palomino/intro-home-5.mp3" )
        PRP.UI.MainMenuIntroSound:SetSoundLevel( 0 )
    end

    PRP.UI.MainMenuIntroSound:Play()

    self:SetSize( ScrW(), ScrH() )

    self:SetTitle( "" )
    self:SetDraggable( false )
    gui.EnableScreenClicker( true )

    local pSelect = vgui.Create( "PRP.Select", self )
    pSelect:SetSize( 300 * PRP.UI.ScaleFactor, 2 * ScrH() / 3 )
    pSelect:SetPos( 275 * PRP.UI.ScaleFactor, 2 * ScrH() / 3 )

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
end

function PANEL:OnRemove()
    gui.EnableScreenClicker( false )
    hook.Remove( "RenderScreenspaceEffects", "PRP.UI.MainMenu.RenderScreenspaceEffects" )
    PRP.UI.MainMenuIntroSound:FadeOut( 5 )
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
end

concommand.Add( "prp_mainmenu", function()
    if PRP.UI.MainMenu then
        PRP.UI.MainMenu:Remove()
        PRP.UI.MainMenu = nil
    else
        PRP.UI.MainMenu = vgui.Create( "PRP.MainMenu" )
    end
end )

vgui.Register( "PRP.MainMenu", PANEL, "DFrame" )