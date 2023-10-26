-- Testing

local PANEL = {}

-- PRP.API.AddMaterial( "ui/splash/bg", "" )

surface.CreateFont( "PRP.Splash.Title", {
    font = "Inter",
    size = 32 * PRP.UI.ScaleFactor,
    weight = 800,
    antialias = true
} )

surface.CreateFont( "PRP.Splash.Subtitle", {
    font = "Inter",
    size = 18 * PRP.UI.ScaleFactor,
    weight = 400,
    antialias = true
} )


local oWarningMat = Material( "prp/warning.png" )

function PANEL:Init()
    self:SetPos( 0, 0 )
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
    -- self:SetMouseInputEnabled( true )
    -- self:SetKeyboardInputEnabled( true )

    -- gui.EnableScreenClicker( true )

    self.Layout = vgui.Create( "DIconLayout", self )
    -- self.Layout:SetSize( ScrW() * 0.4, ScrH() * 0.4 )
    self.Layout:SetStretchWidth( true )
    self.Layout:SetStretchHeight( true )
    self.Layout:SetSpaceX( 100 )
    self.Layout:SetSpaceY( 30 * PRP.UI.ScaleFactor )
    self.Layout:SetLayoutDir( TOP )
    -- self.Layout:SetPos( ScrW() / 2 - self.Layout:GetWide() / 2, ScrH() / 2 - self.Layout:GetTall() / 2 )

    self.Warning = self.Layout:Add( "DImage" )
    self.Warning:SetMaterial( oWarningMat )
    self.Warning:SetSize( 96 * PRP.UI.ScaleFactor, 96 * PRP.UI.ScaleFactor )

    self.Title = self.Layout:Add( "DLabel" )
    self.Title:SetText( "This is an early development build of Palomino." )
    self.Title:SetFont( "PRP.Splash.Title" )
    self.Title:SetTextColor( Color( 255, 255, 255 ) )
    self.Title:SizeToContents()

    self.Subtitle = self.Layout:Add( "DLabel" )
    self.Subtitle:SetText( "Features may be missing, incomplete, or broken. (Trust us, it will look much better than this)" )
    self.Subtitle:SetFont( "PRP.Splash.Subtitle" )
    self.Subtitle:SetTextColor( Color( 255, 255, 255 ) )
    self.Subtitle:SizeToContents()

    self.Subtitle2 = self.Layout:Add( "DLabel" )
    self.Subtitle2:SetText( "Unless directed otherwise, you're free to play the gamemode as you would normally.\nHowever, do not use cheats or exploits targeting the server or other players." )
    self.Subtitle2:SetFont( "PRP.Splash.Subtitle" )
    self.Subtitle2:SetTextColor( Color( 255, 255, 255 ) )
    self.Subtitle2:SizeToContents()

    self.AcceptButton = self.Layout:Add( "PRP.Button" )
    self.AcceptButton:SetLabel( "I Understand" )
    self.AcceptButton.DoClick = function()
        self:Remove()
    end

    self.Layout:InvalidateLayout( true )
    self.Layout:SizeToChildren( false, true )
    self.Layout:SetPos( ScrW() * 0.1, ScrH() / 2 - self.Layout:GetTall() / 2 )

    self.Layout.OnRemove = function()
        hook.Remove( "RenderScreenspaceEffects", "PRP.UI.Splash.RenderScreenspaceEffects" )
    end

    local function fnBackgroundEffects()
        if not self then return end

        local tTable = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.3,
            ["$pp_colour_contrast"] = 0.7,
            ["$pp_colour_colour"] = 0,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        DrawColorModify( tTable )
    end
    hook.Add( "RenderScreenspaceEffects", "PRP.UI.Splash.RenderScreenspaceEffects", fnBackgroundEffects )
end

function PANEL:OnRemove()
    hook.Remove( "RenderScreenspaceEffects", "PRP.UI.Splash.RenderScreenspaceEffects" )
end

function PANEL:Paint( w, h )
    if not PRP.API._bDownloadComplete then return end

    -- surface.SetDrawColor( 255, 255, 255, 64 )
    -- surface.SetMaterial( PRP.API.Material( "ui/splash/bg" ) )
    -- surface.DrawTexturedRect( 0, 0, w, h )
end

function PANEL:PaintOver( w, h )
    if not PRP.API._bDownloadComplete then
        if not self.splashStart then self.splashStart = CurTime() end
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawRect( 0, 0, w, h )

        draw.SimpleText( "Initializing Palomino", "PRP.Splash.Title", w / 2, h / 2 - 128, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "This should only take a few seconds.", "PRP.Splash.Subtitle", w / 2, h / 2 - 128 + (32 * PRP.UI.ScaleFactor), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        draw.SimpleText( "Player", "DebugFixed", w / 2, h / 2 - 64, Color( 210, 210, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( LocalPlayer():SteamName() .. "(" .. LocalPlayer():SteamID64() .. ")", "DebugFixedSmall", w / 2, h / 2 - 64 + 16, Color( 164, 164, 164), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        draw.SimpleText( "PAPI", "DebugFixed", w / 2, h / 2, Color( 210, 210, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "InitComplete: " .. tostring(PRP.API._bInitComplete), "DebugFixedSmall", w / 2, h / 2 + 16, Color( 164, 164, 164), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "DownloadComplete: " .. tostring(PRP.API._bDownloadComplete), "DebugFixedSmall", w / 2, h / 2 + 32, Color( 164, 164, 164), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "MaterialsDownloadQueue: " .. table.Count(PRP.API._tMaterialsDownloadQueue), "DebugFixedSmall", w / 2, h / 2 + 48, Color( 164, 164, 164), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        draw.SimpleText( "Splash", "DebugFixed", w / 2, h / 2 + 64 + 16, Color( 210, 210, 230), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "SplashStart: " .. tostring(self.splashStart), "DebugFixedSmall", w / 2, h / 2 + 64 + 16 + 16, Color( 164, 164, 164), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "Failsafe DC in: " .. tostring(math.Round(30 - CurTime() - self.splashStart)), "DebugFixedSmall", w / 2, h / 2 + 64 + 32 + 16, Color( 164, 164, 164), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        if CurTime() - self.splashStart > 60 then
            RunConsoleCommand( "disconnect" )
        end
    else
        self.splashStart = nil
    end
end

vgui.Register( "PRP.Splash", PANEL, "EditablePanel" )