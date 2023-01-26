--[[
	Chessnut's NPC System
	Do not re-distribute without author's permission.

	Revision 161a9721c14b8ee18ef98bcc99d6c30fe9c195fa2d8e415f3cde1d1c4bdc012d
--]]

include("shared.lua")

-- @TODO: Disable or look into why this is needed
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

end

-- @TODO: PostDrawTranslucentRenderables
function ENT:Draw()
	local realTime = RealTime()

	self:FrameAdvance(realTime - (self.lastTick or realTime))
	self.lastTick = realTime

	self:DrawModel()

	-- @TODO: Draw only when close
	local alpha = math.max((1 - LocalPlayer():GetPos():DistToSqr(self:GetPos()) / 65536) * 255, 0)
	if (alpha == 0) then return end
	
	local aAngles = self:GetAngles()
	aAngles:RotateAroundAxis(aAngles:Up(), 90)
	aAngles:RotateAroundAxis(aAngles:Forward(), 90)

	local vPos = self:GetPos() + Vector(0, 0, 75)

	local sText = #self:GetLabel() > 0 and self:GetLabel() or "NPC"

	surface.SetFont("ix3D2DMediumFont")
	local iTextWidth, iTextHeight = surface.GetTextSize(sText)

	cam.Start3D2D(vPos, aAngles, 0.1)
		draw.SimpleText(sText, "ix3D2DMediumFont", 0, 0, ColorAlpha( color_white, alpha ), 1, 1)
	cam.End3D2D()

	ix.util.PushBlur( function()
		cam.Start3D2D(vPos, aAngles, 0.1)
			surface.SetDrawColor(11, 11, 11, math.max(alpha - 100, 0))
			surface.DrawRect(-iTextWidth / 2 - 20, -iTextHeight / 2 - 10, iTextWidth + 40, iTextHeight + 20)
		cam.End3D2D()
	end )
end