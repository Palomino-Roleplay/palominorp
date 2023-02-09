ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName		= "Dev Entity"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Development"
ENT.Purpose			= "Testbench"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/hunter/blocks/cube075x075x075.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end

	-- Make prop to fall on spawn
	self:PhysWake()
end

function ENT:OnSelectTest()
	print("Testo de mayo")
	surface.PlaySound( "common/bass.wav" )
end

ix.menu.RegisterOption( ENT, "I'm Amazing", {
	OnCanRun = function()
		print("im a rock start")
		return true
	end,
	OnRun = function( eEntity, pPlayer, sOption, tData )
		print("OnRun")
		if CLIENT then
			surface.PlaySound( "common/bass.wav" )
		else
			eEntity:EmitSound( "common/center.wav" )
		end
	end,
} )