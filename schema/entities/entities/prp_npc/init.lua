--[[
	Chessnut's NPC System
	Do not re-distribute without author's permission.

	Revision 161a9721c14b8ee18ef98bcc99d6c30fe9c195fa2d8e415f3cde1d1c4bdc012d
--]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/mossman.mdl")
	self:SetUseType(SIMPLE_USE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(true)
	self:SetSolid(SOLID_BBOX)
	self:PhysicsInit(SOLID_BBOX)

	local physObj = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false)
		physObj:Sleep()
	end

    self:DropToFloor()
end

function ENT:Think()
    local sSequence = "LineIdle03"
    self:ResetSequence( sSequence )
    self:SetSequence( sSequence )
    self:NextThink( CurTime() + self:SequenceDuration() )

    print("think!")
    return true
end