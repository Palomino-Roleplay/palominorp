PRP.UI = PRP.UI or {}

local PANEL = {}

local MAT_STATIC = Material("prp/ui/textures/static.png", "noclamp")
local MAT_LOGO = Material("prp/ui/mainmenu/logo.png")
local MAT_BG = Material("prp/ui/mainmenu/bg.png")

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )

    gui.EnableScreenClicker( true )

    local pSelect = vgui.Create( "PRP.Select", self )
    pSelect:SetSize( 300, 400 )
    pSelect:SetPos( 275, 2 * ScrH() / 3 )

    pSelect:AddButton( "CONTINUE", function( pButton )
        pButton:OpenSubMenu( function( pSubMenu )
            pSubMenu:AddButton( "SYDNEY HUGHES", function()
                print("test")
            end )

            pSubMenu:AddButton( "GEORGE P. BURDELL", function()
                print("test")
            end )

            pSubMenu:AddButton( "AIDEN LANDINI", function()
                print("test")
            end )
        end )
        print("test")
    end )

    pSelect:AddButton( "NEW CHARACTER", function()
        print("test")
    end )

    pSelect:AddButton( "DISCORD", function()
        print("test")
    end )
end

function PANEL:OnRemove()
    gui.EnableScreenClicker( false )
end

function PANEL:Paint()
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