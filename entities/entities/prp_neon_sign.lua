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
end

local function fnDesaturateNeonColor( cColor )
    local iHue, iSaturation, iValue = ColorToHSV( cColor )
    return HSVToColor( iHue, iSaturation * 0.4, iValue )
end

function ENT:Use()
    self:TogglePower()
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

    self:SetSignText( "HUGHES CASINO" )
    self:SetSignType( 1 )
    self:SetSignColor( Vector( 1, 0, 0 ) )
    self:SetSignEnabled( true )
    self:SetColor( fnDesaturateNeonColor( self:GetSignColor():ToColor() ) )
end

local vOffset = Vector( -15, 0, 34 )
local i3D2DScale = 0.25

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

function ENT:DrawTranslucent()
    local iTime = CurTime()
    local iFlickerSpeed = 60
    local iFlickerAmount = 0.1
    local iRandomFactor = 0.15

    local iIntensityBase = 0.9  -- Base light intensity

    -- Calculate flickering light intensity
    local iFX = iIntensityBase + math.sin(iTime * iFlickerSpeed) * iFlickerAmount + math.random() * iRandomFactor

    surface.SetFont( "PRP.Neon.Large" )
    local iTextWidth, iTextHeight = surface.GetTextSize( self:GetSignText() )

    local cColor = self:GetSignColor()
    cColor = isvector( cColor ) and cColor:ToColor() or Color( 255, 255, 255 )

    cColorWashed = fnDesaturateNeonColor( cColor )

    if imgui.Entity3D2D( self, vOffset, Angle( 0, 180, 90 ), i3D2DScale ) then
        if self:GetSignEnabled() then
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", 0, 0, ColorAlpha( cColorWashed, 255 * iFX ) )
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large.Glow", 0, 0, ColorAlpha( cColor, 255 * iFX ) )
        else
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", 0, 0, Color( 64, 64, 64, 200 ) )
        end

        imgui.End3D2D()
    end

    if imgui.Entity3D2D( self, vOffset, Angle( 0, 0, 90 ), i3D2DScale ) then
        if self:GetSignEnabled() then
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", -iTextWidth, 16, ColorAlpha( cColorWashed, 255 * iFX ) )
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large.Glow", -iTextWidth, 16, ColorAlpha( cColor, 255 * iFX ) )
        else
            draw.SimpleText(self:GetSignText(), "PRP.Neon.Large", 0, 0, Color( 64, 64, 64, 64 ) )
        end

        imgui.End3D2D()
    end

    -- if imgui.Entity3D2D( self, vOffset + Vector( 16, 4.5, -28 ), Angle( 0, 180, 90 ), i3D2DScale ) then
    --     if imgui.xButton(5, 5, 36, 8, 8, Color( 120, 120, 120 ), Color( 255, 255, 255 ), Color( 180, 180, 180 ) ) then
    --         self:TogglePower()
    --     end

    --     imgui.End3D2D()
    -- end
end

function ENT:Think()
    if SERVER then return end
    if not self:GetSignEnabled() then return end

    surface.SetFont( "PRP.Neon.Large" )
    local iTextWidth, iTextHeight = surface.GetTextSize( self:GetSignText() )

    local vPos = self:LocalToWorld( vOffset ) + self:GetAngles():Up() * iTextHeight * i3D2DScale * 0.5
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