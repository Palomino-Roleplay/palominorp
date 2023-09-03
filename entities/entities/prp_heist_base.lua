AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName		= "Base"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Heists"
ENT.Purpose			= "Heists Plugin"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:SetHeist( oHeist )
	self.m_oHeist = oHeist

	if SERVER then self:SetNetVar( "heistID", oHeist:GetID() ) end
end

function ENT:GetHeist()
	local sHeistID = self:GetNetVar( "heistID" )
	return self.m_oHeist or ( sHeistID and PRP.Heist.Get( sHeistID ) or nil )
end

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( self.Model or "models/props_combine/combine_interface001.mdl" )

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
end