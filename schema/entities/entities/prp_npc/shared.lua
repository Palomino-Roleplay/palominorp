ENT.Type = "anim"
ENT.PrintName = "NPC"
ENT.Category = "Palomino"
ENT.Author = "sil"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PhysgunDisable = true
ENT.PhysgunDisabled = true

ENT.Sequence = "idle_all_02"

-- Good ones:
-- idle_all_01
-- idle_all_02
-- idle_all_angry
-- idle_all_scared
-- idle_all_cower
-- pose_standing_01
-- pose_standing_02
-- pose_ducking_01
-- pose_ducking_02

-- Funny ones:
-- pose_standing_03
-- pose_standing_04
-- death_01
-- death_02
-- death_03
-- death_04

-- @TODO: Uncomment
-- ENT.PhysgunDisable = true
-- ENT.PhysgunDisabled = true

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Type" )
	self:NetworkVar( "String", 1, "ID" )
end

function ENT:GetNPC()
	return PRP.NPC.List[self:GetID()]
end