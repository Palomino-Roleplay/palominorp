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
    if PRP.UI.PLY_MENU then return end

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

DownloadAPIFiles()
local matInvL = Material( "prp/InventoryL.png" )

surface.CreateFont( "PRP.PlyMenu.Large", {
    font = "Inter Bold",
    size = 48 * PRP.UI.ScaleFactor,
    antialias = true
} )

-- @TODO: Remove
concommand.Add( "prp_ui_download", function()
    DownloadAPIFiles()
end )

function PANEL:Init()
    if not PRP.UI.PlyMenu.tMaterials["plymenu/bg"] then
        DownloadAPIFiles()
        self:Remove()
    end

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

    -- Character Tab
    self.m_pnlTabCharacter, self.m_pnlTabCharacterContent = self.m_pnlTabPanel:AddTab( "CHARACTER" )
    -- self.m_pnlTabCharacter.m_panelContent

    self.m_pnlTabCharacterLeft = vgui.Create( "DPanel", self.m_pnlTabCharacterContent )
    self.m_pnlTabCharacterLeft:SetPos( ScrW() / 2 - PRP.UI.ScaleFactor * 500, 0 )
    self.m_pnlTabCharacterLeft:SetSize( PRP.UI.ScaleFactor * 500, ScrH() - ( 50 * PRP.UI.ScaleFactor ) )

    self.m_pnlTabCharacterLeftInventory = self.m_pnlTabCharacterLeft:Add("ixInventory")
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

    local iInventoryX = self.m_pnlTabCharacterLeft:GetWide() / 2 - (self.m_pnlTabCharacterLeftInventory:GetWide() / 2)
    local iInventoryY = (self.m_pnlTabCharacterLeft:GetTall() - self.m_pnlTabCharacterLeftInventory:GetTall()) / 2
    self.m_pnlTabCharacterLeftInventory:SetPos( iInventoryX, iInventoryY )
    self.m_pnlTabCharacterLeft.Paint = function( p, iW, iH )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetFont( "PRP.PlyMenu.Large" )
        surface.SetTextColor( 255, 255, 255, 255 )
        surface.SetTextPos( iInventoryX, iInventoryY - ( 48 * PRP.UI.ScaleFactor ) )
        surface.DrawText( "INVENTORY" )
    end


    self.m_pnlTabCharacterRight = vgui.Create( "DPanel", self.m_pnlTabCharacterContent )
    self.m_pnlTabCharacterRight:SetPos( ScrW() / 2, 0 )
    self.m_pnlTabCharacterRight:SetSize( PRP.UI.ScaleFactor * 500, ScrH() - ( 50 * PRP.UI.ScaleFactor ) )
    self.m_pnlTabCharacterRight.Paint = function( pnl, w, h )
        surface.SetDrawColor( 255, 255, 255, 80 )
        surface.SetMaterial( Material( "sprites/glow04_noz_gmod", "noclamp smooth" ) )
        surface.DrawTexturedRect( 0, 0, w, h )

        surface.SetDrawColor( 255, 0, 0, 255 )
        surface.SetMaterial( Material( "sprites/glow04_noz_gmod", "smooth" ) )
        surface.DrawTexturedRect( 0, h - 1.6 * h / 7, w, h / 7 )
    end


    local wow = vgui.Create( "DModelPanel", self.m_pnlTabCharacterRight )
    wow:SetPos( 0, 0 )
    wow:Dock( FILL )
    wow:SetModel( LocalPlayer():GetModel() )
    wow:SetFOV( 9 )
    wow:SetAmbientLight( Color( 0, 0, 0 ) )
    wow:SetZPos( 100 )
    wow.bFirstDraw = true

    pac.SetupENT(wow.Entity)

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

        if wow.bFirstDraw then
            wow.bFirstDraw = false

            for sPartID, _ in pairs( LocalPlayer():GetParts() ) do
                ix.pac.AttachPart( wow.Entity, sPartID )
            end
        end

        return
    end
    -- function wow:Paint( w, h )
    --     surface.SetDrawColor( 255, 255, 255, 100 )
    --     surface.DrawOutlinedRect( 0, 0, w, h )
    -- end
    function wow:PaintOver( w, h )
        -- surface.SetDrawColor( 255, 255, 255, 100 )
        -- surface.DrawOutlinedRect( 0, 0, w, h )
    end
    function wow:DrawModel()
        if self.bFirstDraw then
            self.bFirstDraw = false
        end

        -- self.Entity:DrawModel()

        local x, y = self:LocalToScreen(0, 0)
        local w, h = self:GetSize()

        local ang = self.aLookAngle
        if (!ang) then
            ang = (self.vLookatPos - self.vCamPos):Angle()
        end

        pac.DrawEntity2D(self.Entity, x, y, w, h, self:GetCamPos(), ang, self:GetFOV())

        if true then return end

        local oGlowMaterial = Material( "sprites/glow04_noz" )
        local oGlowColor = Color( 255, 255, 255, 255 )

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
end

function PANEL:OnRemove()
    hook.Remove( "RenderScreenspaceEffects", "PRP.UI.PlyMenu.RenderScreenspaceEffects" )
    hook.Remove( "ix.pac.OnPartAttached", "PRP.UI.PlyMenu.OnPartAttached" )
    hook.Remove( "ix.pac.OnPartRemoved", "PRP.UI.PlyMenu.OnPartRemoved" )
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