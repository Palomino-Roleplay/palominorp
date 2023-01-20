SWEP.PrintName              = "Battering Ram"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to ram"
SWEP.Category               = "Palomino: Police"

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.ViewModel			    = "models/weapons/c_rpg.mdl"
SWEP.WorldModel			    = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands               = true

if SERVER then
    util.AddNetworkString( "PRP.BatteringRam.DoorHit" )
end

ix.config.Add( "batteringRamResetTime", 30, "How many minutes for a door to reset after being hit by a battering ram.", nil, {
    data = { min = 1, max = 120 },
    category = "Doors"
} )

local tSurfaceHitSounds = {
    ["metal"] = {
        hit = {
            "physics/metal/metal_barrel_impact_hard1.wav",
            "physics/metal/metal_barrel_impact_hard2.wav",
            "physics/metal/metal_barrel_impact_hard3.wav",
            "physics/metal/metal_barrel_impact_hard5.wav",
            "physics/metal/metal_barrel_impact_hard6.wav",
            "physics/metal/metal_barrel_impact_hard7.wav",
        },
        broke = {
            "physics/metal/metal_box_break1.wav",
            "physics/metal/metal_box_break2.wav",
        }
    },
    ["wood"] = {
        hit = {
            "physics/wood/wood_crate_impact_hard1.wav",
            "physics/wood/wood_crate_impact_hard4.wav",
            "physics/wood/wood_crate_impact_hard5.wav",
            "physics/wood/wood_panel_impact_hard1.wav"
        },
        broke = {
            "physics/wood/wood_box_break1.wav",
            "physics/wood/wood_box_break2.wav",
            "physics/wood/wood_crate_break1.wav",
            "physics/wood/wood_crate_break2.wav",
            "physics/wood/wood_crate_break3.wav",
            "physics/wood/wood_crate_break4.wav",
            "physics/wood/wood_crate_break5.wav",
            "physics/wood/wood_furniture_break1.wav",
            "physics/wood/wood_furniture_break2.wav",
            "physics/wood/wood_plank_break1.wav",
            "physics/wood/wood_plank_break2.wav",
            "physics/wood/wood_plank_break3.wav",
            "physics/wood/wood_plank_break4.wav",
        }
    }
}

function SWEP:Initialize()
    self:SetHoldType( "shotgun" )

    self._lastHit = 0
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SetNextPrimaryFire( CurTime() + 1 )

    local pPlayer = self:GetOwner()

    if not IsValid( pPlayer ) then return end
    if not pPlayer:Alive() then return end
    if pPlayer:InVehicle() then return end
    if not pPlayer:IsPolice() then return end

    local tTrace = pPlayer:GetEyeTraceNoCursor()

    if not tTrace.Entity then return end
    if not tTrace.Entity:IsDoor() then return end

    local eDoor = tTrace.Entity

    if pPlayer:GetPos():DistToSqr( tTrace.HitPos ) > 7500 then return end

    eDoor._lastHit = CurTime()
    self._lastHit = CurTime()

    pPlayer:SetAnimation( PLAYER_ATTACK1 )
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

    if SERVER then
        pPlayer:ViewPunch( Angle( math.random( -5, -20 ), math.random( -2, 2 ), math.random( -5, 5 ) ) )

        local sSurfaceProp = util.GetSurfacePropName( tTrace.SurfaceProps )

        if not tSurfaceHitSounds[sSurfaceProp] then sSurfaceProp = "metal" end

        eDoor._lastHit = eDoor._lastHit or 0

        -- @TODO: Do this a little better
        -- If it's been more than 6 seconds since the last hit, 0% chance of breaking
        local bBreak = false
        if eDoor._lastHit + 6 > CurTime() then
            -- 40% chance of breaking each hit after the first
            bBreak = math.random( 1, 100 ) <= 40
        end

        if bBreak then
            eDoor:EmitSound( table.Random( tSurfaceHitSounds[sSurfaceProp].broke ), 100, 100 )

            -- @TODO: Make the reset time longer than 30 seconds
            local eBrokenDoor = eDoor:BlastDoor( pPlayer:GetAimVector() * 400, ix.config.Get( "batteringRamResetTime", 30 ), false )
            -- eBrokenDoor:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
        else
            eDoor:EmitSound( table.Random( tSurfaceHitSounds[sSurfaceProp].hit ), 100, 100 )
        end

        net.Start( "PRP.BatteringRam.DoorHit" )
            net.WriteEntity( eDoor )
            net.WriteBool( bBreak )
        net.SendPVS( eDoor:GetPos() )
    end
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Reload()
    return
end

function SWEP:CalcViewModelView( eViewModel, vOldEyePos, aOldEyeAng, vEyePos, aEyeAng )
    -- print( CurTime() - ( self._lastHit or 0 ) )
    return  vEyePos + LerpVector(
                                math.ease.OutBack( math.Clamp( ( CurTime() - ( self._lastHit or 0 ) ) / 1, 0, 1 ) ),
                                aOldEyeAng:Forward() * 10,
                                aOldEyeAng:Forward() * 0
                            ) + aOldEyeAng:Up() * -5,
            aEyeAng
    -- return vEyePos + Vector( 0, 0, -5 ), aEyeAng
end

if CLIENT then
    net.Receive( "PRP.BatteringRam.DoorHit", function()
        local eDoor = net.ReadEntity()
        local bBreak = net.ReadBool()

        if not IsValid( eDoor ) then return end

        local oEmitter = ParticleEmitter( eDoor:GetPos(), false )

        for i = 1, 10 do
            local oParticle = oEmitter:Add( "particle/particle_smokegrenade", eDoor:GetPos() + VectorRand( -50, 50 ) )
            if oParticle then
                oParticle:SetDieTime( math.random( 1, 3 ) )

                oParticle:SetStartAlpha( 255 )
                oParticle:SetEndAlpha( 0 )

                oParticle:SetStartSize( 35 )
                oParticle:SetEndSize( 0 )

                oParticle:SetColor( 100, 100, 100 )
                oParticle:SetGravity( Vector( 0, 0, 100 ) )
                oParticle:SetAirResistance( 100 )
                oParticle:SetCollide( true )
                oParticle:SetVelocity( VectorRand( -10, 10 ) )
            end
        end

        oEmitter:Finish()
    end )
end