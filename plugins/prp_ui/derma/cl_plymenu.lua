PRP = PRP or {}
PRP.UI = PRP.UI or {}

PRP.UI.PlyMenu = PRP.UI.PlyMenu or {}
PRP.UI.PlyMenu.tMaterials = PRP.UI.PlyMenu.tMaterials or {}
PRP.UI.PlyMenu.tAPIFiles = PRP.UI.PlyMenu.tAPIFiles or {}
PRP.UI.ScaleFactor = ScrH() / 1080

PRP.UI.PLY_MENU = PRP.UI.PLY_MENU or false

local sAPIURL = "http://loopback.gmod:3000"
local PANEL = {}

local function DownloadAPIFiles()
    PRP.UI.ScaleFactor = ScrH() / 1080
    PRP.UI.tAPIFiles = {
        ["plymenu/bg"] = "plymenu_bg_" .. ScrW() .. "x" .. ScrH() .. "_" .. math.floor( CurTime() ) .. ".png",
    }
    PRP.UI.PlyMenu.tMaterials = {}

    for sFileID, sFileName in pairs( PRP.UI.tAPIFiles ) do
        local sURL = sAPIURL .. "/ui/" .. sFileID .. "/" .. ScrW() .. "/" .. ScrH()

        print( "Downloading " .. sFileID .. " from " .. sURL )
        http.Fetch( sURL, function( data )
            if data then
                if file.Exists( sFileName, "DATA" ) then
                    file.Delete( sFileName, "DATA" )
                end

                file.Write( sFileName, data )
                PRP.UI.PlyMenu.tMaterials[sFileID] = Material( "data/" .. sFileName, "" )

                print( "Downloaded " .. sFileID .. " to " .. sFileName )
            end
        end, function( sError )
            error( sError )
        end )
    end
end

-- @TODO: Remove
concommand.Add( "prp_ui_download", function()
    DownloadAPIFiles()
end )

function PANEL:Init()
    self:SetPos( 0, 0 )
    self:SetSize( ScrW(), ScrH() )

    self:MakePopup()

    self.iOpenTime = CurTime()

    -- Background Panel
    self.m_pnlBackground = vgui.Create( "DPanel", self )
    self.m_pnlBackground:SetPos( 0, 0 )
    self.m_pnlBackground:SetSize( ScrW(), ScrH() )
    self.m_pnlBackground.Paint = function( p, iW, iH )
        ix.util.DrawBlur( p, self.easedFraction * 3 or 0 )
        surface.SetDrawColor( 255, 255, 255, 100 * self.easedFraction )
        surface.SetMaterial( PRP.UI.PlyMenu.tMaterials["plymenu/bg"] )
        surface.DrawTexturedRect( 0, 0, iW, iH )
    end

    local function fnBackgroundEffects()
        if not self then return end

        -- print( math.Clamp( math.TimeFraction( self.iOpenTime, self.iOpenTime + 0.5, CurTime() ), 0, 1 ) )
        self.easedFraction = math.ease.OutCubic( math.Clamp( math.TimeFraction( self.iOpenTime, self.iOpenTime + 0.3, CurTime() ), 0, 1 ) )

        local tTable = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.1 * self.easedFraction,
            ["$pp_colour_contrast"] = 1 - ( 0.2 * self.easedFraction ),
            ["$pp_colour_colour"] = 1 * ( 1 - self.easedFraction ),
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        DrawColorModify( tTable )
    end
    hook.Add( "RenderScreenspaceEffects", "PRP.UI.PlyMenu.RenderScreenspaceEffects", fnBackgroundEffects )

    -- Header Panel
    self.m_pnlTabPanel = vgui.Create( "PRP.TabMenu", self )
    self.m_pnlTabSettings = self.m_pnlTabPanel:AddTab( "SETTINGS" )
    self.m_pnlTabCharacter = self.m_pnlTabPanel:AddTab( "CHARACTER" )
    self.m_pnlTabHelp = self.m_pnlTabPanel:AddTab( "HELP" )
    -- self.m_pnlHeader:SetPos( 0, 0 )
    -- self.m_pnlHeader:SetSize( ScrW(), 100 )

    -- Close Button
    self.m_pnlCloseButton = vgui.Create( "DButton", self )
    self.m_pnlCloseButton:SetSize( 32, 32 )
    self.m_pnlCloseButton:SetText( "" )
    self.m_pnlCloseButton:SetPos( ScrW() - 32, 0 )
    self.m_pnlCloseButton.Paint = function( p, iW, iH )
        draw.SimpleText( "X", "DermaLarge", iW / 2, iH / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.m_pnlCloseButton.DoClick = function()
        self:Remove()
    end
end

function PANEL:OnRemove()
    hook.Remove( "RenderScreenspaceEffects", "PRP.UI.PlyMenu.RenderScreenspaceEffects" )
end

function PANEL:Paint()

end

vgui.Register( "PRP.Menu", PANEL, "DPanel" )

concommand.Add( "prp_menu", function()
    if PRP.UI.PLY_MENU then
        PRP.UI.PLY_MENU:Remove()
        PRP.UI.PLY_MENU = false
    else
        PRP.UI.PLY_MENU = vgui.Create( "PRP.Menu" )
    end
end )