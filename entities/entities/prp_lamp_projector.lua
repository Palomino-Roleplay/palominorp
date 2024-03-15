AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName		= "Lamp Projector"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Palomino"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= false

ENT.RenderGroup 	= RENDERGROUP_BOTH

ENT.SampleColors    = {
    Vector( 0.8, 0.2, 0.2 ),
    Vector( 0.2, 0.8, 0.2 ),
    Vector( 0.2, 0.2, 0.8 ),
    Vector( 0.8, 0.8, 0.2 ),
    Vector( 0.2, 0.8, 0.8 ),
    Vector( 0.8, 0.2, 0.8 )
}


function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/maxofs2d/thruster_projector.mdl" )

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

    -- self:SetRenderFX( kRenderFxSpotlight )

    -- self:SetSignText( "FOO BAR" )
    -- self:SetSignType( 1 )
    self:SetLampColor( Vector( 1, 0, 0 ) )

    self:SetRenderMode( RENDERMODE_TRANSCOLOR )

    if SERVER then
        local eEffect = ents.Create( "prop_effect" )
        eEffect:SetModel( "models/effects/vol_light64x256.mdl" ) -- @TODO: Consider adding different modes
        eEffect:SetParent( self )
        eEffect:SetLocalPos( Vector( 0, 6, 0 ) )
        eEffect:SetLocalAngles( Angle( 180, 0, 0 ) )
        eEffect:SetRenderMode( RENDERMODE_TRANSCOLOR )
        eEffect:Spawn()

        timer.Simple( 0, function()
            eEffect.AttachedEntity:SetRenderMode( RENDERMODE_TRANSCOLOR )
            eEffect.AttachedEntity:SetColor( Color( 0, 0, 0, 255 ) )
            -- eEffect:SetRenderMode( 4 )
        end )

        self.eEffect = eEffect
    end
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

function ENT:SetupDataTables()
    self:NetworkVar( "Vector", 0, "LampColor" )
    self:NetworkVar( "Bool", 0, "LampEnabled" )
    self:NetworkVar( "Entity", 0, "Effect" )

    self:SetLampColor( self.SampleColors[math.random( 1, #self.SampleColors )] )
    self:SetLampEnabled( false )
    self:SetColor( Color( 128, 128, 128 ) )
end

local vOffset = Vector( -15, 0, 34 )
local i3D2DScale = 0.25

function ENT:GetEffectEntity()
    if self.eEffect then return self.eEffect end

    for _, eChild in pairs( self:GetChildren() ) do
        if eChild:GetClass() == "prop_effect" then
            self.eEffect = eChild
            return eChild
        end
    end

    return NULL
end

function ENT:TogglePower()
    self:SetLampEnabled( !self:GetLampEnabled() )

    if self:GetLampEnabled() then
        self:EmitSound( "buttons/button1.wav" )
        self:SetColor( fnDesaturateNeonColor( self:GetLampColor():ToColor() ) )
        -- self.eEffect:SetColor( self:GetLampColor():ToColor() )

        if self:GetEffectEntity() then
            self:GetEffectEntity().AttachedEntity:SetColor( self:GetLampColor():ToColor() )
        end
    else
        self:EmitSound( "buttons/lightswitch2.wav" )
        self:SetColor( Color( 128, 128, 128 ) )

        if self:GetEffectEntity() then
            self:GetEffectEntity().AttachedEntity:SetColor( Color( 0, 0, 0, 0 ) )
        end
    end
end

function ENT:DrawTranslucent()
    if imgui.Entity3D2D( self, vOffset + Vector( 24, 0, 8 ), Angle( 0, 90, 90 ), i3D2DScale * 0.25 ) then
        if imgui.xButton(-30, 20, 60, 30, 20, Color( 120, 120, 120 ), Color( 255, 255, 255 ), Color( 180, 180, 180 ) ) then
            self:TogglePower()
        end

        imgui.End3D2D()
    end
end