AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName		= "Money Printer"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Printing money."
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

ENT.RenderGroup 	= RENDERGROUP_BOTH

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/props/m5521cdn.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end

	-- Make prop to fall on spawn
	self:PhysWake()
end

function ENT:DrawTranslucent()
    if imgui.Entity3D2D(self, Vector(7.5, -11.9, 24.1), Angle(0, 90, 15), 0.025) then

        surface.SetDrawColor( 10, 23, 28, 255 )
        surface.DrawRect( 0, 0, 750, 128 )

        imgui.End3D2D()
    end
end