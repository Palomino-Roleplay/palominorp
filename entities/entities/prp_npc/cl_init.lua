include("shared.lua")

-- @TODO: Disable or look into why this is needed
ENT.AutomaticFrameAdvance = true

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self:SetFlexWeight( 0, 0.5 )
    self:SetFlexWeight( 1, 0.5 )
    self:SetFlexWeight( 2, 0.5 )
    self:SetFlexWeight( 3, 0.5 )

    self.nextAnim = 0

    timer.Simple( IsValid(LocalPlayer()) and 1 or 5, function()
        -- self:Anim()
    end )

    self:UseClientSideAnimation()

    self.enteredTime = 0
    self.enteredElapsedTime = 0
    self.currentString = ""
end

function ENT:Anim()
    -- if self.nextAnim and self.nextAnim > CurTime() then return end

    -- Print("ANIM!")

    -- self:ResetSequence( self.Sequence )
    -- self.nextAnim = CurTime() + 1
    self:AnimHead()
end

function ENT:AnimHead()
    -- @TODO Good enough for now, but would be nice to have it track exactly + have the eyes look at the player too.
    local aAngle = self:WorldToLocal( LocalPlayer():EyePos() ):Angle()
    aAngle:Normalize()

    self:InvalidateBoneCache()
    self:SetPoseParameter( "head_yaw", aAngle.y )
end

function ENT:Think()
    -- @TODO: Consider getting rid of this or making it more efficient (SlowThink maybe?)

    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 65536 then
        self:SetNextClientThink( CurTime() + 1 )
        return true
    end

    self:Anim()

    return true
end

function ENT:Draw()
    local realTime = RealTime()

	self:FrameAdvance(realTime - (self.lastTick or realTime))
	self.lastTick = realTime

    self:DrawModel()
end

local sExampleVoiceLine = "damn hes short asl"
local iTriggerDistance = 200
local iSecondsPerCharacter = 0.08

function ENT:DrawTranslucent()
    if LocalPlayer():GetPos():Distance( self:GetPos() ) > iTriggerDistance then
        self.enteredTime = 0
        return
    elseif self.enteredTime == 0 then
        self.enteredTime = CurTime()
    end
    self.enteredElapsedTime = CurTime() - self.enteredTime

    local iLastStringLength = string.len( self.currentString )
    self.currentString = string.sub( sExampleVoiceLine, 1, self.enteredElapsedTime / iSecondsPerCharacter )
    if string.len( self.currentString ) > iLastStringLength and self.currentString[string.len( self.currentString )] != ' ' then
        surface.PlaySound( "physics/concrete/concrete_impact_soft3.wav" )
    end

    print(self.enteredElapsedTime)
    print(self.currentString)

    local vOffset = Vector( 0, 0, 80 )

    if imgui.Entity3D2D( self, vOffset, Angle( 0, 90, 90 ), 0.2 ) then
        draw.SimpleTextOutlined( self.currentString, "Trebuchet24", 0, 0, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 255 ) )

        imgui.End3D2D()
    end
end

-- @TODO: PostDrawTranslucentRenderables
-- function ENT:Draw()
-- 	local realTime = RealTime()

-- 	self:FrameAdvance(realTime - (self.lastTick or realTime))
-- 	self.lastTick = realTime

-- 	self:DrawModel()

-- 	-- @TODO: Draw only when close
-- 	local alpha = math.max((1 - LocalPlayer():GetPos():DistToSqr(self:GetPos()) / 65536) * 255, 0)
-- 	if (alpha == 0) then return end
	
-- 	local aAngles = self:GetAngles()
-- 	aAngles:RotateAroundAxis(aAngles:Up(), 90)
-- 	aAngles:RotateAroundAxis(aAngles:Forward(), 90)

-- 	local vPos = self:GetPos() + Vector(0, 0, 75)

-- 	local sText = #self:GetLabel() > 0 and self:GetLabel() or "NPC"

-- 	surface.SetFont("ix3D2DMediumFont")
-- 	local iTextWidth, iTextHeight = surface.GetTextSize(sText)

-- 	cam.Start3D2D(vPos, aAngles, 0.1)
-- 		draw.SimpleText(sText, "ix3D2DMediumFont", 0, 0, ColorAlpha( color_white, alpha ), 1, 1)
-- 	cam.End3D2D()

-- 	ix.util.PushBlur( function()
-- 		cam.Start3D2D(vPos, aAngles, 0.1)
-- 			surface.SetDrawColor(11, 11, 11, math.max(alpha - 100, 0))
-- 			surface.DrawRect(-iTextWidth / 2 - 20, -iTextHeight / 2 - 10, iTextWidth + 40, iTextHeight + 20)
-- 		cam.End3D2D()
-- 	end )
-- end