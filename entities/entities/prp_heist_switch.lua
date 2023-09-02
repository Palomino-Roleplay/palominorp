AddCSLuaFile()

DEFINE_BASECLASS( "prp_heist_base" )

ENT.Type            = "anim"
ENT.Base            = "prp_heist_base"

ENT.PrintName		= "Panel"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Heists"
ENT.Purpose			= "Heists Plugin"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

-- @TODO: Change to a better button
ENT.Model           = "models/props_lab/tpswitch.mdl"

function ENT:Initialize()
    BaseClass.Initialize( self )
end

local oGlowMaterial = Material("particle/particle_glow_05_addnofog")
if CLIENT then
    surface.CreateFont( "PRP.Heist.Switch.CodeText", {
        font = "Oxygen Mono",
        size = 48,
        weight = 400,
        antialias = true,
        additive = true,
    })

    function ENT:KeypadType( iKey )
        local sCode = self:GetNetVar( "code", "" )

        if #sCode >= 4 then return end

        surface.PlaySound( "buttons/button17.wav" )
        net.Start( "PRP_Heist_Switch.KeypadType" )
            net.WriteEntity( self )
            net.WriteUInt( iKey, 4 )
        net.SendToServer()
    end
elseif SERVER then
    if SERVER then util.AddNetworkString( "PRP_Heist_Switch.KeypadType" ) end

    function ENT:Toggle()
        local bStatus = self:GetNetVar( "state", false )
        self:SetNetVar( "state", not bStatus )

        if not self:GetHeist() then return end
        local oHeist = self:GetHeist()
        local tTurrets = oHeist:GetTurrets() or {}

        for _, eTurret in pairs( tTurrets ) do
            if not IsValid( eTurret ) then continue end

            eTurret:Fire( bStatus and "enable" or "disable" )
        end
    end

    function ENT:KeypadType( iKey )
        local sCode = self:GetNetVar( "code", "" )

        if #sCode >= 4 then return end

        local sNewCode = sCode .. iKey
        self:SetNetVar( "code", sNewCode )

        if #sNewCode >= 4 then
            if sNewCode == "1337" then
                self:EmitSound( "buttons/button3.wav" )
                self:Toggle()
            else
                self:EmitSound( "buttons/button8.wav" )
            end

            timer.Simple( 1, function()
                self:SetNetVar( "code", "" )
            end )
        end
    end

    net.Receive( "PRP_Heist_Switch.KeypadType", function( _, pPlayer )
        local eEntity = net.ReadEntity()
        local iKey = net.ReadUInt( 4 )

        local tTrace = util.TraceLine( {
            start = pPlayer:GetShootPos(),
            endpos = pPlayer:GetShootPos() + pPlayer:GetAimVector() * 96,
            filter = pPlayer
        } )

        -- @TODO: Note this & log it for anti-exploit purposes.
        if not IsValid( tTrace.Entity ) or tTrace.Entity ~= eEntity then return end

        eEntity:KeypadType( iKey )
    end )
end

function ENT:DrawTranslucent( iFlags )
    if not self:GetHeist() then return end

    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)

    self:DrawModel()

    render.SetStencilCompareFunction(STENCIL_EQUAL)

    -- @TODO: Store vector in a variable (and do this for all)
    if imgui.Entity3D2D(self, Vector(4, -7.6, 1.1), Angle(0, 90, 90), 0.025) then
        -- Code
        surface.SetFont( "PRP.Heist.Switch.CodeText" )
        local sCode = self:GetNetVar( "code", "" )
        local iCodeWidth, iCodeHeight = surface.GetTextSize( sCode )
        surface.SetTextPos( 26, ( -iCodeHeight / 2 ) - 30 )
        surface.SetTextColor( 150, 187, 171 )
        surface.DrawText( sCode )

        -- Keypad
        for i = 1, 9 do
            local iXPos = (i - 1) % 3
            local iYPos = math.floor((i - 1) / 3)

            local iX = iXPos * 48
            local iY = iYPos * 48

            surface.SetDrawColor( 0, 0, 0, 235 )
            surface.DrawRect( iX, iY, 48, 48 )
            if imgui.xTextButton(i, "!Inter@32", iX, iY, 48, 48, 4, Color( 77, 100, 113 ), Color( 151, 163, 170), Color( 98, 128, 151) ) then
                self:KeypadType( i )
            end
        end


        imgui.End3D2D()
    end

    local bStatus = self:GetNetVar( "state", false )

    -- @TODO: Looks cool, but prob way too expensive.

    local iTime = CurTime()
    local iFlickerSpeed = 60
    local iFlickerAmount = 0.025
    local iRandomFactor = 0.05

    local iIntensityBase = 0.9  -- Base light intensity

    -- Calculate flickering light intensity
    local iFX = iIntensityBase + math.sin(iTime * iFlickerSpeed) * iFlickerAmount + math.random() * iRandomFactor

    -- Make the sprites draw on top of the entity no matter what
    render.SetMaterial( oGlowMaterial )
    cam.IgnoreZ(true)

    if bStatus then
        render.DrawSprite( self:GetPos() + self:GetForward() * 4 + self:GetRight() * -1 + self:GetUp() * -0.5, 16, 16, Color( 80 * iFX, 255 * iFX, 80 * iFX ) )
    else
        render.DrawSprite( self:GetPos() + self:GetForward() * 4 + self:GetRight() * -1 + self:GetUp() * 2.75, 16, 16, Color( 255 * iFX, 80 * iFX, 80 * iFX ) )
    end

    -- Turrets
    for i, eTurret in ipairs( self:GetHeist():GetTurrets() or {} ) do
        if not IsValid( eTurret ) then continue end

        local iSequence = eTurret:GetSequence()

        local bTargeting = iSequence >= 1 and iSequence <= 3
        local bShooting = iSequence == 2
        local bDisabled = eTurret:Health() <= 0

        local vRightOffset = self:GetRight() * (bTargeting and -5.25 or -3.65)

        local oTurretColor

        if bTargeting then
            oTurretColor = bShooting and Color( 255 * iFX, 80 * iFX, 80 * iFX, 255 ) or Color( 255 * iFX, 255 * iFX, 80 * iFX, 255 )
        elseif bDisabled then
            oTurretColor = Color( 80 * iFX, 255 * iFX, 80 * iFX, 255 )
        else
            oTurretColor = Color( 255 * iFX, 80 * iFX, 80 * iFX, 255 )
        end

        render.DrawSprite( self:GetPos() + self:GetForward() * 2 + vRightOffset + ( self:GetUp() * ( -9 + ( 0.7 * i ) ) ), 5, 4, oTurretColor )
    end

    -- Bank Alarm
    local iAlarmState = self:GetHeist():GetAlarmState()

    local oAlarmColor
    if iAlarmState == PRP.Heist.ALARM_STATE_DISARMED then
        oAlarmColor = Color( 80 * iFX, 255 * iFX, 80 * iFX, 255 )
    elseif iAlarmState == PRP.Heist.ALARM_STATE_ARMED then
        oAlarmColor = Color( 255 * iFX, 255 * iFX, 80 * iFX, 255 )
    elseif iAlarmState == PRP.Heist.ALARM_STATE_ACTIVE then
        oAlarmColor = Color( 255 * iFX, 80 * iFX, 80 * iFX, 255 )
    end

    local vRightOffset = self:GetRight() * (iAlarmState == PRP.Heist.ALARM_STATE_ACTIVE and -3.65 or -5.25)
    render.DrawSprite( self:GetPos() + self:GetForward() * 2 + vRightOffset + ( self:GetUp() * ( -10.1 ) ), 7, 5, oAlarmColor )

    render.SetStencilEnable(false)
    cam.IgnoreZ(false)
end

function ENT:Draw()
    -- self:DrawModel()
end