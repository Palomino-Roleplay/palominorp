AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName		= "Neon Sign"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Palomino"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.RenderGroup 	= RENDERGROUP_BOTH

ENT.SampleColors    = {
    Vector( 1, 0, 0 ),
    Vector( 0, 1, 0 ),
    Vector( 0, 0, 1 ),
    Vector( 1, 1, 0 ),
    Vector( 0, 1, 1 ),
    Vector( 1, 0, 1 ),
    Vector( 1, 1, 1 )
}

if SERVER then
    util.AddNetworkString( "PRP.NeonSign.EditText" )
    net.Receive( "PRP.NeonSign.EditText", function( _, pPlayer )
        -- @TODO: Ensure player is allowed to edit this sign
        local eSign = net.ReadEntity()
        local sText = net.ReadString()

        sText = string.upper( sText )
        sText = string.gsub( sText, "[^%w%s?]", "" )

        sText = string.sub( sText, 0, 16 )

        -- @TODO: Profanity filter

        eSign:SetSignText( sText )
    end )
end

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/props_combine/combine_light002a.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
	end

	-- Make prop to fall on spawn
	self:PhysWake()

    self:SetRenderFX( kRenderFxSpotlight )

    -- self:SetSignText( "FOO BAR" )
    -- self:SetSignType( 1 )
    -- self:SetSignColor( Vector( 1, 0, 0 ) )

    -- @TODO: Consider spawning w/ an (invisible?) 2x10 or something block to avoid the text clipping into walls.
end

local function fnDesaturateNeonColor( cColor )
    local iHue, iSaturation, iValue = ColorToHSV( cColor )
    return HSVToColor( iHue, iSaturation * 0.4, iValue )
end

function ENT:Use()
    -- self:TogglePower()
end

function ENT:Draw()
    self:DrawModel()
end

if CLIENT then
    surface.CreateFont( "PRP.Neon.Large", {
        font = "KosanNonCommercial",
        size = 100,
        antialias = true,
        additive = false,
    } )

    surface.CreateFont( "PRP.Neon.Large.Glow", {
        font = "KosanNonCommercial",
        size = 100,
        blursize = 16,
        antialias = true,
        additive = true,
    } )
end

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "SignText" )
    self:NetworkVar( "Int", 0, "SignType" )
    self:NetworkVar( "Vector", 0, "SignColor" )
    self:NetworkVar( "Bool", 0, "SignEnabled" )
    self:NetworkVar( "Bool", 1, "SignVertical" )
    self:NetworkVar( "Float", 0, "SignScale" )

    self:SetSignText( "SYDNEYS" )
    self:SetSignType( 1 )

    local vColor = self.SampleColors[math.random( 1, #self.SampleColors )]
    self:SetSignColor( vColor )
    self:SetSignEnabled( true )
    self:SetSignVertical( false )
    self:SetSignScale( 0.25 )
    self:SetColor( fnDesaturateNeonColor( self:GetSignColor():ToColor() ) )
end

function ENT:TogglePower()
    self:SetSignEnabled( !self:GetSignEnabled() )

    if self:GetSignEnabled() then
        self:EmitSound( "buttons/button1.wav" )
        self:SetColor( fnDesaturateNeonColor( self:GetSignColor():ToColor() ) )
    else
        self:EmitSound( "buttons/lightswitch2.wav" )
        self:SetColor( Color( 128, 128, 128 ) )
    end
end

function ENT:DrawSignText( cColor, cColorWashed, iFX, iX, bDrawVertical, iTextHeight )
    -- Assuming this is already inside a 3D2D context

    if self:GetSignEnabled() then
        if bDrawVertical then
            for i = 1, string.len( self:GetSignText() ), 1 do
                -- pauses
                draw.SimpleText(self:GetSignText()[i], "PRP.Neon.Large", iX, 0 + (iTextHeight * 0.9 * (i - 1)), ColorAlpha( cColorWashed, 255 * iFX ) )
            end
        else
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", iX, 15 * 1 / self:GetSignScale(), ColorAlpha( cColorWashed, 255 * iFX ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large.Glow", iX, 15 * 1 / self:GetSignScale(), ColorAlpha( cColor, 255 * iFX ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        end
    else
        draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", iX, 16, Color( 64, 64, 64, 128 ) )
    end
end

local vOffset = Vector( -15, 0, 34 )
local vOffsetVertical = Vector( -10, 0, 9 )
local i3D2DScale = 0.4

hook.Add( "PostDrawTranslucentRenderables", "PRP.NeonSign.PostDrawTranslucentRenderables", function( bDrawingDepth, bDrawingSkybox, bIsDraw3DSkybox )
    -- @TODO: Optimize
    -- @TODO: Optimization: Don't render past a certain distance (but should be a pretty damn far distance)

    for _, eEntity in pairs( ents.FindByClass( "prp_neon_sign" ) or {} ) do
        local iTime = CurTime()
        local iFlickerSpeed = 60
        local iFlickerAmount = 0.1
        local iRandomFactor = 0.15

        local iIntensityBase = 0.9  -- Base light intensity
        local iFX = iIntensityBase + math.sin(iTime * iFlickerSpeed) * iFlickerAmount + math.random() * iRandomFactor

        surface.SetFont( "PRP.Neon.Large" )
        local iTextWidth, iTextHeight = surface.GetTextSize( eEntity:GetSignText() )

        local cColor = eEntity:GetSignColor()
        cColor = isvector( cColor ) and cColor:ToColor() or Color( 255, 255, 255 )

        cColorWashed = fnDesaturateNeonColor( cColor )

        if eEntity:GetSignVertical() then
            if imgui.Entity3D2D( eEntity, vOffsetVertical, Angle( -90, 180, 90 ), eEntity:GetSignScale() ) then
                eEntity:DrawSignText( cColor, cColorWashed, iFX, 0, true, iTextHeight )

                imgui.End3D2D()
            end

            if imgui.Entity3D2D( eEntity, vOffsetVertical, Angle( 90, 0, 90 ), eEntity:GetSignScale() ) then
                eEntity:DrawSignText( cColor, cColorWashed, iFX, -iTextHeight * 0.65, true, iTextHeight )

                imgui.End3D2D()
            end
        else
            if imgui.Entity3D2D( eEntity, vOffset, Angle( 0, 180, 90 ), eEntity:GetSignScale() ) then
                eEntity:DrawSignText( cColor, cColorWashed, iFX, 0, false, iTextHeight )

                imgui.End3D2D()
            end

            if imgui.Entity3D2D( eEntity, vOffset, Angle( 0, 0, 90 ), eEntity:GetSignScale() ) then
                eEntity:DrawSignText( cColor, cColorWashed, iFX, -iTextWidth, false, iTextHeight )

                imgui.End3D2D()
            end
        end

        if imgui.Entity3D2D( eEntity, vOffset + Vector( 24, 0, 8 ), Angle( 0, 90, 90 ), eEntity:GetSignScale() * 0.25 ) then
            if imgui.xButton(-30, 20, 60, 30, 20, Color( 120, 120, 120 ), Color( 255, 255, 255 ), Color( 180, 180, 180 ) ) then
                eEntity:TogglePower()
            end

            if imgui.xTextButton("EDIT", "!Inter@16", -25, 60, 50, 32, 4, Color( 120, 120, 120 ), Color( 255, 255, 255 ), Color( 180, 180, 180 ) ) then
                -- eEntity:KeypadType( i )
                -- eEntity:TogglePower()

                Derma_StringRequest(
                    "Neon Sign",
                    "Enter your desired text",
                    "OPEN",
                    function( sText )
                        net.Start( "PRP.NeonSign.EditText" )
                            net.WriteEntity( eEntity )
                            net.WriteString( sText )
                        net.SendToServer()
                    end,
                    nil,
                    "Submit",
                    "Cancel"
                )
            end

            imgui.End3D2D()
        end
    end
end )

-- function ENT:DrawTranslucent()
--     local iTime = CurTime()
--     local iFlickerSpeed = 60
--     local iFlickerAmount = 0.1
--     local iRandomFactor = 0.15

--     local iIntensityBase = 0.9  -- Base light intensity

--     -- Calculate flickering light intensity
--     local iFX = iIntensityBase + math.sin(iTime * iFlickerSpeed) * iFlickerAmount + math.random() * iRandomFactor

--     surface.SetFont( "PRP.Neon.Large" )
--     local iTextWidth, iTextHeight = surface.GetTextSize( self:GetSignText() )

--     local cColor = self:GetSignColor()
--     cColor = isvector( cColor ) and cColor:ToColor() or Color( 255, 255, 255 )

--     cColorWashed = fnDesaturateNeonColor( cColor )

--     if imgui.Entity3D2D( self, vOffset, Angle( 0, 180, 90 ), i3D2DScale ) then
--         if self:GetSignEnabled() then
--             draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", 0, 16, ColorAlpha( cColorWashed, 255 * iFX ) )
--             draw.SimpleText(self:GetSignText(), "PRP.Neon.Large.Glow", 0, 16, ColorAlpha( cColor, 255 * iFX ) )
--         else
--             draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", 0, 16, Color( 64, 64, 64, 128 ) )
--         end

--         imgui.End3D2D()
--     end

--     if imgui.Entity3D2D( self, vOffset, Angle( 0, 0, 90 ), i3D2DScale ) then
--         if self:GetSignEnabled() then
--             draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", -iTextWidth, 16, ColorAlpha( cColorWashed, 255 * iFX ) )
--             draw.SimpleText(self:GetSignText(), "PRP.Neon.Large.Glow", -iTextWidth, 16, ColorAlpha( cColor, 255 * iFX ) )
--         else
--             draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", -iTextWidth, 16, Color( 64, 64, 64, 128 ) )
--         end

--         imgui.End3D2D()
--     end

--     if imgui.Entity3D2D( self, vOffset + Vector( 24, 0, 8 ), Angle( 0, 90, 90 ), i3D2DScale * 0.25 ) then
--         if imgui.xButton(-30, 20, 60, 30, 20, Color( 120, 120, 120 ), Color( 255, 255, 255 ), Color( 180, 180, 180 ) ) then
--             self:TogglePower()
--         end

--         if imgui.xTextButton("EDIT", "!Inter@16", -25, 60, 50, 32, 4, Color( 120, 120, 120 ), Color( 255, 255, 255 ), Color( 180, 180, 180 ) ) then
--             -- self:KeypadType( i )
--             -- self:TogglePower()

--             Derma_StringRequest(
--                 "Neon Sign",
--                 "Enter your desired text",
--                 "OPEN",
--                 function( sText )
--                     net.Start( "PRP.NeonSign.EditText" )
--                         net.WriteEntity( self )
--                         net.WriteString( sText )
--                     net.SendToServer()
--                 end,
--                 nil,
--                 "Submit",
--                 "Cancel"
--             )
--         end

--         imgui.End3D2D()
--     end
-- end

function ENT:Think()
    if SERVER then return end
    if not self:GetSignEnabled() then return end

    surface.SetFont( "PRP.Neon.Large" )
    local iTextWidth, iTextHeight = surface.GetTextSize( self:GetSignText() )

    local vPos = self:LocalToWorld( vOffset ) - self:GetAngles():Up() * iTextHeight * i3D2DScale * 0.5
    vPos = vPos + self:GetAngles():Forward() * -iTextWidth * i3D2DScale * 0.5

    local oDLight = DynamicLight( self:EntIndex(), false )
	if ( oDLight ) then
		oDLight.pos = vPos
		oDLight.r = self:GetSignColor().x * 255
		oDLight.g = self:GetSignColor().y * 255
		oDLight.b = self:GetSignColor().z * 255
		oDLight.brightness = 1
        oDLight.noworld = false
		oDLight.decay = 1000
		oDLight.size = iTextWidth * i3D2DScale * 2
        oDLight.style = 6
		oDLight.dietime = CurTime() + 1
        oDLight.dir = self:GetAngles():Forward()
        -- oDLight.innerangle = 1
        -- oDLight.outerangle = 1
	end
end