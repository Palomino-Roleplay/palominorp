PRP.UI = PRP.UI or {}

local PANEL = {}

local MAT_STATIC = Material("prp/ui/textures/static.png", "noclamp")
local MAT_LOGO = Material("prp/ui/mainmenu/logo.png")
local MAT_BG = Material("prp/ui/mainmenu/bg.png")

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )

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
end

function PANEL:OnRemove()
    gui.EnableScreenClicker( false )
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
    // Repeat original 512x512 texture over the screen
    surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 0, 0, ScrW() / 512, ScrH() / 512 )

    surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( MAT_LOGO )
    surface.DrawTexturedRect( 275, ( ScrH() - 82 ) / 2, 291, 82 )
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