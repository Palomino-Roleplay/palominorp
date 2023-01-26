--[[
	Chessnut's NPC System
	Do not re-distribute without author's permission.

	Revision 161a9721c14b8ee18ef98bcc99d6c30fe9c195fa2d8e415f3cde1d1c4bdc012d
--]]

ENT.Type = "anim"
ENT.PrintName = "NPC"
ENT.Author = "sil"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PhysgunDisable = true
ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Label")
	self:NetworkVar("Color", 0, "Vector")
end