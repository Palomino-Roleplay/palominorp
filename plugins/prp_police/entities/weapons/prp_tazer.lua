SWEP.PrintName              = "Tazer"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to stun"
SWEP.Category               = "Palomino: Police"

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.Damage = 1
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.Ammo = "Pistol"

SWEP.Primary.DefaultClip = 1
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = .2
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 100

SWEP.Secondary.ClipSize         = -1
SWEP.Secondary.DefaultClip      = -1
SWEP.Secondary.Automatic        = false
SWEP.Secondary.Ammo         = "none"

SWEP.ViewModel              = Model("models/realistic_police/taser/c_taser.mdl")
SWEP.WorldModel             = Model("models/realistic_police/taser/w_taser.mdl")
SWEP.ViewModelFOV           = 60
SWEP.UseHands               = true

SWEP.DrawAmmo               = true

SWEP.HoldType               = "Pistol"
SWEP.base                   = "weapon_base"

function SWEP:Initialize()
    self:SendWeaponAnim( ACT_VM_DRAW )
    self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
end

function SWEP:DoShootEffects( tTrace )
    self:EmitSound("rptstungunshot2.mp3")
    self:ShootEffects()

    local effectShoot = EffectData()
    effectShoot:SetOrigin( tTrace.HitPos )
    effectShoot:SetStart( self:GetOwner():GetShootPos() )
    effectShoot:SetAttachment( 1 )
    effectShoot:SetEntity( self )

    util.Effect( "ToolTracer", effectShoot )

    -- Light effect when shooting tazer

    if not CLIENT then return end

    local eViewModel = self:GetOwner():GetViewModel()
    if not IsValid( eViewModel ) then return end

    local iAttachment = eViewModel:LookupAttachment( "muzzle" )
    if not iAttachment then return end

    local tAttachment = eViewModel:GetAttachment( iAttachment )
    if not tAttachment then return end

    local vPos = tAttachment.Pos
    local aAng = tAttachment.Ang

    local vForward = aAng:Forward()
    local vRight = aAng:Right()
    local vUp = aAng:Up()

    local vOffset = vPos + vForward * 30 + vRight * 1 + vUp * -1

    -- @TODO: Consider lighting the world (2nd arg to false) with a clientside performance setting
    local tLight = DynamicLight( eViewModel:EntIndex(), true )
    if tLight then
        tLight.Pos = vOffset
        tLight.r = 60
        tLight.g = 120
        tLight.b = 255
        tLight.Brightness = 1
        tLight.dir = vForward
        tLight.Size = 512
        tLight.Decay = 256
        tLight.DieTime = CurTime() + 0.15
    end
end

function SWEP:DoHitEffects( pTarget, tTrace )
    if CLIENT then return end

    pTarget:EmitSound( "ambient/voices/" .. pTarget:GetSex()[1] .. "_scream1.wav" )
    pTarget:EmitSound( "rptstungunmain.mp3" )

    local effectHit = EffectData()
    effectHit:SetOrigin( tTrace.HitPos )
    effectHit:SetNormal( Vector( 0, 0, 0.3 ) )
    effectHit:SetAngles( pTarget:GetAngles() )

    util.Effect( "ManhackSparks", effectHit, true, true )
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end

    self:SetNextPrimaryFire( CurTime() + 5 )
    if CLIENT then
        timer.Simple( 5, function()
            if not IsValid( self ) then return end
            if not self:GetOwner():Alive() then return end
            if self:GetOwner():GetActiveWeapon() ~= self then return end

            self:EmitSound( "buttons/blip1.wav", 50, 120, 0.25, CHAN_WEAPON )
        end )
    end

    local tTrace = self:GetOwner():GetEyeTraceNoCursor()
    local pTarget = tTrace.Entity

    if not IsValid( pTarget ) or not pTarget:IsPlayer() then
        self:DoShootEffects( tTrace )
        return
    end

    if pTarget == self:GetOwner() then return end

    if pTarget:GetPos():DistToSqr( self:GetOwner():GetPos() ) > 250000 then
        self:DoShootEffects( tTrace )
        return
    end

    if pTarget:GetCharacter():IsPolice() then
        if SERVER then self:GetOwner():Notify( "You can't taze government officials!" ) end
        return
    end

    self:DoShootEffects( tTrace )
    self:DoHitEffects( tTrace.Entity, tTrace )

    local rnda = self.Primary.Recoil * -1
    local rndb = self.Primary.Recoil * math.random(-1, 1)

    self:ShootEffects()

    self:GetOwner():ViewPunch( Angle( rnda,rndb,rnda ) )

    if CLIENT then return end

    pTarget:Taze( self:GetOwner() )
end

function SWEP:SecondaryAttack()

end