--[[
	Chessnut's NPC System
	Do not re-distribute without author's permission.

	Revision 161a9721c14b8ee18ef98bcc99d6c30fe9c195fa2d8e415f3cde1d1c4bdc012d
--]]

include("shared.lua")

ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

end

function ENT:Draw()
	local realTime = RealTime()

	self:FrameAdvance(realTime - (self.lastTick or realTime))
	self.lastTick = realTime

	self:DrawModel()
end