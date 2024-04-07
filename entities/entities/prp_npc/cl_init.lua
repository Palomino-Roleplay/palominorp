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

local tExampleTextLines = {
    "ay, what the fuck are you doing?",
    "fuck off.",
    "leave me the fuck alone.",
    "carry on, will ya?",
    "beat it.",
    "i fucking hate this city.",
}

function ENT:GetTextLine()
    return self.dialogue or tExampleTextLines[(self:EntIndex() % #tExampleTextLines) + 1]
end

function ENT:SetTextLine( sDialogue )
    self.dialogue = sDialogue
    self.enteredTime = CurTime()
end

local sExampleVoiceLine = ""
local iTriggerDistance = 164
local iSecondsPerCharacter = 0.07

function ENT:DrawTranslucent()
    if LocalPlayer():GetPos():Distance( self:GetPos() ) > iTriggerDistance then
        self.enteredTime = 0
        return
    elseif self.enteredTime == 0 then
        self.enteredTime = CurTime()
    end
    self.enteredElapsedTime = CurTime() - self.enteredTime

    local sOurString = self:GetTextLine() or "simulation paused"
    -- @TODO: Draw black outline around the speech text when the NPC is selected.

    local iLastStringLength = string.len( self.currentString )
    self.currentString = string.sub( sOurString, 1, self.enteredElapsedTime / iSecondsPerCharacter )
    if string.len( self.currentString ) > iLastStringLength and self.currentString[string.len( self.currentString )] != ' ' then
        -- surface.PlaySound( "physics/concrete/concrete_impact_soft3.wav" )
        surface.PlaySound( "prp/ui/hover.wav" )
    end

    print(self.enteredElapsedTime)
    print(self.currentString)

    local vOffset = Vector( 0, 0, 75 )

    cam.IgnoreZ( true )
    if imgui.Entity3D2D( self, vOffset, Angle( 0, 90, 90 ), 0.03 ) then
        draw.SimpleTextOutlined( self.currentString, "PRP.UI.Nameplates.ID", 0, 0, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, Color( 0, 0, 0, 255 ) )

        imgui.End3D2D()
    end

    if imgui.Entity3D2D( self, vOffset, Angle( 0, -90, 90 ), 0.03 ) then
        draw.SimpleTextOutlined( self.currentString, "PRP.UI.Nameplates.ID.Blurred", 0, 0, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, Color( 0, 0, 0, 255 ) )

        imgui.End3D2D()
    end
    cam.IgnoreZ( false )
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

local iTempSelectedOption = 0 -- @TODO: Don't do it like this please.
local iTempOpenTime = 0
local iConfigFadeTime = 0.8
local bTempAnyOverlaps = false
local tOptions = {"'i wanna be a cop'", "'id like to turn myself in'", "'id like to pay my ticket'"}
hook.Add( "PostDrawTranslucentRenderables", "PUI.DrawInteractionEffects", function( bDrawingDepth, bDrawingSkybox )
    if bDrawingSkybox then return end
    if not LocalPlayer():KeyDown( IN_USE ) then
        iTempOpenTime = 0

        if iTempSelectedOption != -1 then
            surface.PlaySound( "prp/ui/click.wav" )

            for _, ent in pairs( ents.FindByClass( "prp_npc" ) ) do
                if iTempSelectedOption == 1 then
                    ent:SetTextLine( "how about you hit the gym first?" )

                    tOptions = {"'low blow man...'", "'go fuck yourself.'", "'ugh, fine.'"}
                elseif iTempSelectedOption == 2 then
                    ent:SetTextLine( "fuck off you little bitch." )

                    tOptions = {1, 2, 3, 4, "a lot"}
                elseif iTempSelectedOption == 3 then
                    ent:SetTextLine( "palomino pd, how can i help you?" )
                    tOptions = {"'i wanna be a cop'", "'id like to turn myself in'", "'id like to pay my ticket'"}
                end
            end

            iTempSelectedOption = -1
        end
        return
    end

    if iTempOpenTime == 0 then
        iTempOpenTime = CurTime()
    end

    local iTempFadePerc = math.min( CurTime() - iTempOpenTime, iConfigFadeTime ) / iConfigFadeTime
    iTempFadePerc = math.ease.OutElastic( iTempFadePerc )
    Print( "Fade Perc: ", iTempFadePerc )

    -- Alpha fade
    surface.SetAlphaMultiplier( iTempFadePerc )

	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	-- Enable stencils
	render.SetStencilEnable( true )
	-- Force everything to fail
	render.SetStencilCompareFunction( STENCIL_NEVER )
	-- Save all the things we don't draw
	render.SetStencilFailOperation( STENCIL_REPLACE )

	-- Set the reference value to 00011100
	render.SetStencilReferenceValue( 0x1C )
	-- Set the write mask to 01010101
	-- Any writes to the stencil buffer will be bitwise ANDed with this mask.
	-- With our current reference value, the result will be 00010100.
	render.SetStencilWriteMask( 0x55 )

	-- Fail to draw our entities.
	for _, ent in ipairs( ents.FindByClass( "prp_npc" ) ) do
		ent:DrawModel()
	end

	-- Set the test mask to 11110011.
	-- Any time a pixel is read out of the stencil buffer it will be bitwise ANDed with this mask.
	render.SetStencilTestMask( 0xF3 )
	-- Set the reference value to 00011100 & 01010101 & 11110011
	render.SetStencilReferenceValue( 0x10 )
	-- Pass if the masked buffer value matches the unmasked reference value
	-- render.SetStencilCompareFunction( STENCIL_GREATER )

	-- Draw our entities
	-- render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )
    local plyMat = Material( "prp/ui/temp/glow.png" )

    for _, ent in ipairs( ents.FindByClass( "prp_npc" ) ) do
        if ent == LocalPlayer() then continue end

        render.SetStencilCompareFunction( STENCIL_GREATER )
        local targetPos = ent:GetPos() + ent:OBBCenter() -- Center of the target player's bounding box
        local dir = LocalPlayer():GetPos() - targetPos
        local ang = dir:Angle()

        -- Since we're using 3D2D, flip the pitch angle 90 degrees to orient correctly
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 90)
        -- ang.pitch = 0

        local vPos = ent:GetPos() + ent:OBBCenter()
        local vHeadPos = vPos + Vector( 0, 0, 32 )
        local iScaleFactor = 1 / ent:GetPos():Distance( LocalPlayer():GetPos() )

        local iInitialWidth = 40000
        local iInitialHeight = 75000

        local tScreenPos = vPos:ToScreen()
        local iX = tScreenPos.x - ( iInitialWidth / 2 * iScaleFactor )
        local iY = tScreenPos.y - ( iInitialHeight / 2 * iScaleFactor )

        local tHeadScreenPos = vHeadPos:ToScreen()

        local iWidth = iInitialWidth * iScaleFactor
        local iHeight = iInitialHeight * iScaleFactor

        local iSelectX = tScreenPos.x + ( 10000 * iScaleFactor )
        local iSelectY = tScreenPos.y - ( 20000 * iScaleFactor * ( 0.9 + iTempFadePerc / 10 ) )

        Print("what???")
        Print( iWidth )

        cam.Start2D()
            surface.SetDrawColor( 255, 255, 255, 64 )
            surface.DrawLine( tHeadScreenPos.x, tHeadScreenPos.y, iSelectX, iSelectY )

            render.OverrideDepthEnable( true, false )

            surface.SetMaterial(plyMat)
            surface.SetDrawColor(255, 255, 255, 48)

            -- Print( iX, ",\t", iY, ",\t", iWidth, ",\t", iHeight )

            surface.DrawTexturedRect(iX, iY, iWidth, iHeight) -- Centered on the player's bounding box

            -- surface.SetDrawColor( 255, 0, 0, 255 )
            -- surface.DrawRect( iX, iY, iWidth, iHeight )

            render.OverrideDepthEnable( false )
        cam.End2D()

        -- cam.Start3D2D(targetPos, ang, 0.1)
        --     render.OverrideDepthEnable( true, false )

        --     surface.SetMaterial(plyMat)
        --     surface.SetDrawColor(255, 255, 255, 64)
            
        --     -- The size of the texture in the 3D world. You might need to adjust these values
        --     local w, h = 800, 1200
        --     surface.DrawTexturedRect(-w/2, -h/2, w, h) -- Centered on the player's bounding box

        --     render.OverrideDepthEnable( false )
        -- cam.End3D2D()

        render.SetStencilCompareFunction( STENCIL_GREATEREQUAL )

        cam.Start2D()


            local iCursorX, iCursorY = ScrW() / 2, ScrH() / 2
            local iOptionWidth = 250
            local iOptionHeight = 40

            -- local bOverlapsX = false
            -- local bOverlapsY = false
            -- local bOverlaps = false

            local tNPCOptions = ent.options or tOptions

            surface.SetMaterial( Material( "gui/gradient" ) )
            surface.SetDrawColor( 32, 36, 42, 160 )
            surface.DrawTexturedRect( iSelectX + 2, iSelectY, iOptionWidth, iOptionHeight * #tNPCOptions )

            -- Line to NPC


            local bAnyOverlaps = false
            for i, sOption in ipairs(tNPCOptions) do
                local bOverlapsX = iSelectX < iCursorX and iSelectX + iOptionWidth > iCursorX
                local bOverlapsY = iSelectY < iCursorY and iSelectY + iOptionHeight > iCursorY
                local bOverlaps = bOverlapsX and bOverlapsY

                if bOverlaps then
                    if i != iTempSelectedOption then
                        surface.PlaySound( "prp/ui/hover.wav" )
                    end

                    bAnyOverlaps = true
                    bTempAnyOverlaps = true

                    iTempSelectedOption = i

                    surface.SetDrawColor( PUI.GREEN:Unpack() )
                    surface.DrawRect( iSelectX, iSelectY, 2, 40 )

                    PUI.StartOverlay()
                        surface.SetMaterial( Material( "prp/ui/temp/gradient_overlay2_left.png" ) )
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.DrawRect( iSelectX + 2, iSelectY, iOptionWidth, iOptionHeight )
                    PUI.EndOverlay()

                    surface.SetMaterial( Material( "gui/gradient" ) )
                    surface.SetDrawColor( ColorAlpha( PUI.GREEN, 64 ):Unpack() )
                    surface.DrawTexturedRect( iSelectX + 2, iSelectY, iOptionWidth, iOptionHeight )

                    surface.SetTextColor( 255, 255, 255, 255 )
                    surface.SetFont( "PRP.UI.Interaction.Option" )
                    surface.SetTextPos( iSelectX + 20, iSelectY + ( ( iOptionHeight / 2 ) / 2 ) )
                    surface.DrawText( sOption )

                    -- surface.SetDrawColor( ColorAlpha( PUI.GREEN, 255 ):Unpack() )
                    -- surface.DrawRect( iSelectX, iSelectY, 2, iOptionHeight )
                else
                    surface.SetDrawColor( 255, 255, 255, 64 )
                    surface.DrawRect( iSelectX, iSelectY, 2, iOptionHeight )

                    surface.SetTextColor( 255, 255, 255, 64 )
                    surface.SetFont( "PRP.UI.Interaction.Option" )
                    surface.SetTextPos( iSelectX + 20, iSelectY + ( ( iOptionHeight / 2 ) / 2 ) )
                    surface.DrawText( sOption )
                end

                iSelectY = iSelectY + iOptionHeight
            end

            -- A little gradient on the bottom to hold the box up in the air
            surface.SetMaterial( Material( "gui/gradient" ) )
            surface.SetDrawColor( 255, 255, 255, 64 )
            if iTempSelectedOption == #tNPCOptions then
                surface.SetDrawColor( PUI.GREEN:Unpack() )
            end
            surface.DrawTexturedRect( iSelectX, iSelectY, iOptionWidth, 2 )

            if not bTempAnyOverlaps then
                iTempSelectedOption = -1
            end

            if not bAnyOverlaps and bTempAnyOverlaps then
                bTempAnyOverlaps = false
            end

            Print( iTempSelectedOption )

            -- 2

            -- iSelectY = iSelectY + iOptionHeight

            -- bOverlapsX = iSelectX < iCursorX and iSelectX + iOptionWidth > iCursorX
            -- bOverlapsY = iSelectY < iCursorY and iSelectY + iOptionHeight > iCursorY
            -- bOverlaps = bOverlapsX and bOverlapsY
            -- print("Overlaps 2: ", bOverlapsX, bOverlapsY, bOverlapsX and bOverlapsY)

            -- surface.SetDrawColor( 255, 255, 255, 128 )
            -- surface.DrawRect( iSelectX, iSelectY, 2, 40 )

            -- surface.SetTextColor( 255, 255, 255, 128 )
            -- surface.SetFont( "PRP.UI.Interaction.Option" )
            -- surface.SetTextPos( iSelectX + 20, iSelectY + ( ( iOptionHeight / 2 ) / 2 ) )
            -- surface.DrawText( "COPY STEAMID" )

            -- -- 3

            -- iSelectY = iSelectY + iOptionHeight

            -- bOverlapsX = iSelectX < iCursorX and iSelectX + iOptionWidth > iCursorX
            -- bOverlapsY = iSelectY < iCursorY and iSelectY + iOptionHeight > iCursorY
            -- print("Overlaps 3: ", bOverlapsX, bOverlapsY, bOverlapsX and bOverlapsY)

            -- surface.SetDrawColor( 255, 255, 255, 64 )
            -- surface.DrawRect( iSelectX, iSelectY, 2, iOptionHeight )

            -- surface.SetTextColor( 255, 255, 255, 64 )
            -- surface.SetFont( "PRP.UI.Interaction.Option" )
            -- surface.SetTextPos( iSelectX + 20, iSelectY + ( ( iOptionHeight / 2 ) / 2 ) )
            -- surface.DrawText( "PAT DOWN" )
        cam.End2D()
    end


    for _, ent in ipairs( ents.FindByClass( "prp_npc" ) ) do
        PUI.StartOverlay()
            -- @TODO: Something
            surface.SetMaterial( Material( "effects/flashlight/soft" ) )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        PUI.EndOverlay()
    end

	-- Let everything render normally again
	render.SetStencilEnable( false )
    surface.SetAlphaMultiplier( 1 )
end )