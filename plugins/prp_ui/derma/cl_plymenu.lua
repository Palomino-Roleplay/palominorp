PRP = PRP or {}
PRP.UI = PRP.UI or {}

PRP.UI.PlyMenu = PRP.UI.PlyMenu or {}
PRP.UI.PlyMenu.tMaterials = PRP.UI.PlyMenu.tMaterials or {}
PRP.UI.PlyMenu.tAPIFiles = PRP.UI.PlyMenu.tAPIFiles or {}

local PANEL = {}

PRP.API.AddMaterial( "ui/plymenu/youbg", "" )
PRP.API.AddMaterial( "ui/plymenu/bg", "" )

local oGradient = Material( "prp/ui/temp/gradient.png" )
local oGlowMat = Material( "prp/ui/temp/ply_glow.png", "" )

-- local function DownloadAPIFiles()
--     -- if true then return end
--     if IsValid( PRP.UI.PLY_MENU ) then return end

--     PRP.UI.tAPIFiles = {
--         ["plymenu/youbg"] = "plymenu_youbg_" .. ScrW() .. "x" .. ScrH() .. "_" .. math.floor( CurTime() ) .. ".png",
--         ["plymenu/bg"] = "plymenu_bg_" .. ScrW() .. "x" .. ScrH() .. "_" .. math.floor( CurTime() ) .. ".png",
--     }
--     PRP.UI.PlyMenu.tMaterials = {}

--     for sFileID, sFileName in pairs( PRP.UI.tAPIFiles ) do
--         local sURL = PRP.API_URL .. "/ui/" .. sFileID .. "/" .. ScrW() .. "/" .. ScrH()

--         print( "Downloading " .. sFileID .. " from " .. sURL )
--         http.Fetch( sURL, function( data )
--             if data then
--                 if file.Exists( sFileName, "DATA" ) then
--                     file.Delete( sFileName, "DATA" )
--                 end

--                 file.Write( sFileName, data )
--                 PRP.UI.PlyMenu.tMaterials[sFileID] = Material( "data/" .. sFileName, "" )

--                 print( "Downloaded " .. sFileID .. " to " .. sFileName )
--             end
--         end, function( sError )
--             error( sError )
--         end, {
--             apikey = PRP.API_KEY,
--             steamid = LocalPlayer():SteamID64(),
--             steamname = LocalPlayer():SteamName()
--         } )
--     end
-- end

-- local matInvL = Material( "prp/InventoryL.png" )

surface.CreateFont( "PRP.PlyMenu.Large", {
    font = "Inter Bold",
    size = 48 * PRP.UI.ScaleFactor,
    antialias = true
} )

surface.CreateFont( "PRP.PlyMenu.Sub", {
    font = "Inter",
    size = 20 * PRP.UI.ScaleFactor,
    antialias = true
} )

function PANEL:Init()
    self:SetPos( 0, 0 )
    self:SetSize( ScrW(), ScrH() )

    self:MakePopup()
    self:SetKeyboardInputEnabled( false )

    self.iOpenTime = CurTime()

    -- Background Panel
    self.m_pnlBackground = vgui.Create( "DPanel", self )
    self.m_pnlBackground:SetPos( 0, 0 )
    self.m_pnlBackground:SetSize( ScrW(), ScrH() )

    local function fnBackgroundEffects()
        if not self then return end

        -- print( math.Clamp( math.TimeFraction( self.iOpenTime, self.iOpenTime + 0.5, CurTime() ), 0, 1 ) )
        self.easedFraction = math.ease.OutCubic( math.Clamp( math.TimeFraction( self.iOpenTime, self.iOpenTime + 0.3, CurTime() ), 0, 1 ) )

        local iFactor = 1
        local iFactorAdjusted = iFactor + 1
        local iFactorInverseSquare = 1 / ( iFactorAdjusted * iFactorAdjusted )

        local iFactor = 2

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
    hook.Add( "RenderScreenspaceEffects", "PRP.UI.PlyMenu.RenderScreenspaceEffects", fnBackgroundEffects )

    -- Header Panel
    self.m_pnlTabPanel = vgui.Create( "PRP.TabMenu", self )
    self.m_pnlTabSettings = self.m_pnlTabPanel:AddTab( "SETTINGS" )

    self.m_pnlTabSettings = self.m_pnlTabPanel:AddTab( "SCOREBOARD" )

    -- Character Tab
    self.m_pnlTabCharacter, self.m_pnlTabCharacterContent = self.m_pnlTabPanel:AddTab( "YOU" )
    -- self.m_pnlTabCharacter.m_panelContent

    self.m_pnlTabCharacterLeft = vgui.Create( "DPanel", self.m_pnlTabCharacterContent )
    self.m_pnlTabCharacterLeft:SetPos( ScrW() / 2 - PRP.UI.ScaleFactor * 500, 0 )
    self.m_pnlTabCharacterLeft:SetSize( PRP.UI.ScaleFactor * 500, ScrH() - ( 100 * PRP.UI.ScaleFactor ) )

    self.m_pnlTabCharacterLeftInventory = self.m_pnlTabCharacterLeft:Add("ixInventory")
    self.m_pnlTabCharacterLeftInventory:SetIconSize( 80 * PRP.UI.ScaleFactor )
    self.m_pnlTabCharacterLeftInventory:SetPos(0, 0)
    self.m_pnlTabCharacterLeftInventory:SetDraggable(false)
    self.m_pnlTabCharacterLeftInventory:SetSizable(false)
    self.m_pnlTabCharacterLeftInventory:SetTitle(nil)
    self.m_pnlTabCharacterLeftInventory.bNoBackgroundBlur = true
    self.m_pnlTabCharacterLeftInventory.childPanels = {}

    local inventory = LocalPlayer():GetCharacter():GetInventory()
    
    if (inventory) then
        self.m_pnlTabCharacterLeftInventory:SetInventory(inventory)
    end
    ix.gui.inv1 = self.m_pnlTabCharacterLeftInventory

    local iInventoryX = self.m_pnlTabCharacterLeft:GetWide() / 2 - (self.m_pnlTabCharacterLeftInventory:GetWide() / 2)
    local iInventoryY = (self.m_pnlTabCharacterLeft:GetTall() - self.m_pnlTabCharacterLeftInventory:GetTall()) / 2
    self.m_pnlTabCharacterLeftInventory:SetPos( iInventoryX, iInventoryY )
    self.m_pnlTabCharacterLeft.Paint = function( p, iW, iH )
        surface.SetFont( "PRP.PlyMenu.Large" )
        surface.SetTextColor( 203, 233, 255, 255 )
        surface.SetTextPos( iInventoryX, iInventoryY - ( (16 + 64) * PRP.UI.ScaleFactor ) )
        surface.DrawText( string.upper( LocalPlayer():GetCharacter():GetName() ) )

        surface.SetFont( "PRP.PlyMenu.Sub" )
        surface.SetTextColor( 172, 213, 243, 255 * 0.15 )
        surface.SetTextPos( iInventoryX, iInventoryY - ( (16 + 16) * PRP.UI.ScaleFactor ) )
        surface.DrawText( string.upper( "UNEMPLOYED" ) )
    end


    self.m_pnlTabCharacterRight = vgui.Create( "DPanel", self.m_pnlTabCharacterContent )
    self.m_pnlTabCharacterRight:SetPos( ScrW() / 2, 20 * PRP.UI.ScaleFactor )
    self.m_pnlTabCharacterRight:SetSize( PRP.UI.ScaleFactor * 500, ScrH() - ( 120 * PRP.UI.ScaleFactor ) )
    self.m_pnlTabCharacterRight.Paint = function( pnl, w, h )
        -- surface.SetDrawColor( 255, 255, 255, 128 )
        -- surface.SetMaterial( Material( "prp/light2.png", "" ) )
        -- surface.DrawTexturedRect( 0, 0, w, h )

        -- surface.SetDrawColor( 255, 255, 255, 255 )
        -- surface.SetMaterial( Material( "prp/shadow.png", "" ) )
        -- surface.DrawTexturedRect( w * 0.25 / 2, h - 1.8 * h / 8, w * 0.75, h / 8 )

        -- surface.SetDrawColor( 255, 255, 255, 255 * self.easedFraction )
        -- surface.SetMaterial( Material( "prp/plybg.png", "smooth" ) )
        -- surface.DrawTexturedRect( 0, h * 0.1, w, h * 0.8 )
    end


    local wow = vgui.Create( "DModelPanel", self.m_pnlTabCharacterRight )
    wow:Dock( FILL )
    wow:SetModel( LocalPlayer():GetModel() )
    wow:SetFOV( 7.5 )
    wow:SetAmbientLight( Color( 0, 0, 0 ) )
    wow:SetZPos( 100 )

    pac.SetupENT(wow.Entity)

    for sPartID, _ in pairs( LocalPlayer():GetParts() ) do
        ix.pac.AttachPart( wow.Entity, sPartID )
    end

    hook.Add( "ix.pac.OnPartAttached", "PRP.UI.PlyMenu.OnPartAttached", function( eEntity, sPartID )
        if ( eEntity == LocalPlayer() ) then
            ix.pac.AttachPart( wow.Entity, sPartID )
        end
    end )

    hook.Add( "ix.pac.OnPartRemoved", "PRP.UI.PlyMenu.OnPartRemoved", function( eEntity, sPartID )
        if ( eEntity == LocalPlayer() ) then
            ix.pac.RemovePart( wow.Entity, sPartID )
        end
    end )

    -- hook.Add( "PreDrawHalos", "toiasjdoisjad", function()
    --     print( wow.Entity )
    --     halo.Add( { wow.Entity }, Color( 255, 0, 0, 255 * easedFrac ), 1, 1, 1, true, true )
    -- end )

    function wow:LayoutEntity( eEntity )
        if ( self.bAnimated ) then
            self:RunAnimation()
        end

        eEntity:SetSkin( LocalPlayer():GetSkin() )
        eEntity:SetBodyGroups( LocalPlayer():GetBodyGroupsString() )

        return
    end
    function wow:DrawPACEntity()
        local x, y = self:LocalToScreen(0, 0)
        local w, h = self:GetSize()

        local ang = self.aLookAngle
        if (!ang) then
            ang = (self.vLookatPos - self.vCamPos):Angle()
        end

        pac.DrawEntity2D(self.Entity, x, y, w, h, self:GetCamPos(), ang, self:GetFOV())
    end
    -- function wow:Paint( w, h )
    --     -- local x, y = self:LocalToScreen(0, 0)
    --     -- local w, h = self:GetSize()
    --     -- surface.SetMaterial( Material( "prp/plyshadow.png", "smooth" ) )
    --     -- surface.SetDrawColor( 255, 255, 255, 255 )
    --     -- surface.DrawTexturedRect( - ( 747 - w ) / 2, 0, 747, h )
    -- end
    function wow:PaintOver( w, h )
        render.SetScissorRect(0, 0, ScrW(), ScrH(), false)

        -- surface.SetDrawColor( 255, 255, 255, 255 * 1 )
        -- surface.SetMaterial( oGlowMat )
        -- surface.DrawTexturedRect( 0, 0, 744, 1080 )

        render.SetScissorRect(0, 0, ScrW(), ScrH(), true)
    end
    function wow:DrawModel()
        -- self.Entity:DrawModel()
        -- local oGlowMaterial = Material( "sprites/glow04_noz" )
        -- local oGlowColor = Color( 255, 255, 255, 255 )

        render.SetModelLighting(0, 1, 1, 1)
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

        -- self.Entity:DrawModel()
        wow:DrawPACEntity()

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

            -- self.Entity:DrawModel()
            wow:DrawPACEntity()

            -- Set the test mask to 11110011.
            -- Any time a pixel is read out of the stencil buffer it will be bitwise ANDed with this mask.
            render.SetStencilTestMask( 0xF3 )
            -- Set the reference value to 00011100 & 01010101 & 11110011
            render.SetStencilReferenceValue( 0x10 )
            -- Pass if the masked buffer value matches the unmasked reference value
            render.SetStencilCompareFunction( STENCIL_EQUAL )

            cam.Start2D()
                -- render.OverrideBlend( true, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_SRC_ALPHA, BLENDFUNC_ADD )
                
                surface.SetMaterial( Material( "prp/coooolers.png", "" ) )
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

        wow:SetDirectionalLight(BOX_TOP, (Color(71, 172, 255):ToVector() * 1):ToColor())
        wow:SetDirectionalLight(BOX_BACK, (Color(0, 0, 0):ToVector() * 1):ToColor())
        wow:SetDirectionalLight(BOX_LEFT, (Color(52, 124, 184):ToVector() * 1):ToColor())
        wow:SetDirectionalLight(BOX_BOTTOM, (Color(93, 57, 151):ToVector() * 1):ToColor())
        wow:SetDirectionalLight(BOX_RIGHT, (Color(44, 104, 71):ToVector() * 1):ToColor())
        wow:SetDirectionalLight(BOX_FRONT, (Color(255, 255, 255):ToVector() * 1):ToColor())
    end

    local headpos = wow.Entity:GetBonePosition(wow.Entity:LookupBone("ValveBiped.Bip01_Head1"))
    local spinepos = wow.Entity:GetBonePosition(wow.Entity:LookupBone("ValveBiped.Bip01_Spine"))
    wow:SetLookAt(spinepos-Vector(0, 0, 7))
    wow:SetCamPos(spinepos-Vector(-90 * 3, -50 * 3, 0))
    wow.Entity:SetEyeTarget( headpos + Vector( 16, 1, 0 ) )

    wow:SetAnimated( true )
    timer.Simple(0, function()
        wow.Entity:ResetSequence( wow.Entity:LookupSequence( "idle_all_01" ) )
    end )

    self.m_pnlTabSettings = self.m_pnlTabPanel:AddTab( "COMMUNITY" )
    
    -- Help Tab
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

    -- Background Paint

    self.m_pnlBackground.Paint = function( p, iW, iH )
        ix.util.DrawBlur( p, self.easedFraction * 6 or 0 )


        PUI.StartOverlay()
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( oGradient )
            surface.DrawTexturedRect( 0, 0, iW, iH )

            surface.DrawRect( 0, 0, iW, iH )
        PUI.EndOverlay()

        Print( "eased fraction: " .. self.easedFraction )

        surface.SetDrawColor( 255, 255, 255, 255 * 0.3 * self.easedFraction )
        surface.SetMaterial( oGradient )
        surface.DrawTexturedRect( 0, 0, iW, iH )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 1 * self.easedFraction )
        -- surface.SetMaterial( oGradient )
        -- surface.DrawTexturedRect( 0, 0, iW, iH )

        -- render.OverrideBlend( true, BLEND_DST_COLOR, BLEND_DST_ALPHA, BLENDFUNC_ADD, BLEND_SRC_COLOR, BLEND_DST_ALPHA, BLENDFUNC_ADD )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 1 * self.easedFraction )
        -- surface.SetMaterial( oGradient )
        -- surface.DrawTexturedRect( 0, 0, iW, iH )

        -- render.OverrideBlend( false )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 1 * self.easedFraction )
        -- surface.SetMaterial( Material( "prp/Footer.png", "" ) )
        -- surface.DrawTexturedRect( 0, iH - 74, iW, 74 )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 0.1 * self.easedFraction )

        -- local x, y = wow:LocalToScreen(0, 0)
        -- local w, h = wow:GetSize()
        -- surface.SetMaterial( Material( "prp/webcontent8.png", "smooth" ) )
        -- surface.SetDrawColor( 255, 255, 255, 255 )
        -- surface.DrawTexturedRect( x + (w - 747)/2, y, 747, 1080 )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 0.7 * self.easedFraction )
        -- surface.SetMaterial( Material( "prp/noise.png", "" ) )
        -- surface.DrawTexturedRect( 0, 0, iW, iH )

        -- surface.SetDrawColor( 0, 0, 0, 255 * 0.15 )
        -- surface.DrawRect( 0, 0, iW, iH )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 0.5 * self.easedFraction )
        -- surface.SetMaterial( PRP.UI.PlyMenu.tMaterials["plymenu/bg"] )
        -- surface.DrawTexturedRect( 0, 0, iW, iH )

        -- surface.SetDrawColor( 255, 255, 255, 255 * 0.4 * self.easedFraction )
        -- surface.SetMaterial( Material( "prp/lighting3.png", "smooth" ) )
        -- surface.DrawTexturedRect( 0, 0, iW, iH )

        -- surface.SetDrawColor( 0, 0, 0, 255 * 0.3 * self.easedFraction )
        -- surface.DrawRect( 0, 0, iW, iH )
    end
end

function PANEL:OnRemove()
    hook.Remove( "RenderScreenspaceEffects", "PRP.UI.PlyMenu.RenderScreenspaceEffects" )
    hook.Remove( "ix.pac.OnPartAttached", "PRP.UI.PlyMenu.OnPartAttached" )
    hook.Remove( "ix.pac.OnPartRemoved", "PRP.UI.PlyMenu.OnPartRemoved" )

    ix.gui["inv"..LocalPlayer():GetCharacter():GetInventory():GetID()] = nil
end

function PANEL:Paint()

end

print("Alive check")

vgui.Register( "PRP.Menu", PANEL, "DPanel" )

-- concommand.Add( "prp_menu", function()
--     if PRP.UI.PLY_MENU then
--         PRP.UI.PLY_MENU:Remove()
--         PRP.UI.PLY_MENU = false
--     else
--         PRP.UI.PLY_MENU = vgui.Create( "PRP.Menu" )
--     end
-- end )