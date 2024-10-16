AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/player/breen.mdl" )
	self:SetUseType(SIMPLE_USE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self:SetSolid(SOLID_BBOX)
	self:PhysicsInit(SOLID_BBOX)

	-- @TODO: Fix NPCs slightly floating
	local physObj = self:GetPhysicsObject()
	self:DropToFloor()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false)
		physObj:Sleep()
	end

    self:ResetSequence( self.Sequence )
end

function ENT:Think()
    -- self:ResetSequence( sSequence )
    -- self:SetSequence( sSequence )
    -- self:NextThink( CurTime() + self:SequenceDuration() )

    return true
end

function ENT:Use( pPlayer )
	if self:GetNPC() then
		self:GetNPC():Use( pPlayer )

		if self:GetNPC().networkUse then
			net.Start( "PRP.NPC.Use" )
				net.WriteEntity( self )
			net.Send( pPlayer )
		end
	end
end