SWEP.PrintName              = "Handcuffs"
SWEP.Author                 = "Kobralost & sil"
SWEP.Instructions           = "Primary Fire: handcuff.\nSecondary Fire: uncuff."
SWEP.Category               = "Palomino: Police"

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.ViewModel              = Model("models/realistic_police/handcuffs/c_handcuffs.mdl")
SWEP.WorldModel             = Model("models/realistic_police/handcuffs/w_handcuffs.mdl")
SWEP.ViewModelFOV           = 80
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

-- @TODO: Figure out what the fuck is wrong with these animations

function SWEP:Initialize()
    self:SetHoldType( "passive" )
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self.Weapon:EmitSound("rpthandcuffdeploy.mp3")
end

function SWEP:CanCuff( pVictim )
    local pOfficer = self:GetOwner()

    if not pVictim:IsPlayer() then return false end
    if not pVictim:GetCharacter() or not pOfficer:GetCharacter() then return false end
    if pVictim:GetPos():DistToSqr( pOfficer:GetPos() ) > 8000 then return false end

    return true
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local pOfficer = self:GetOwner()
    local pVictim = pOfficer:GetEyeTrace().Entity

    self:SetNextPrimaryFire( CurTime() + 0.5 )

    if not self:CanCuff( pVictim ) then return end
    if pVictim:IsHandcuffed() then return end

    if SERVER then
        -- @TODO: Fix the animation
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

        pVictim:Handcuff()
    end

    -- @TODO: Check if other players can hear this
    self.Weapon:EmitSound("rpthandcuffleftclick.mp3")
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    local pOfficer = self:GetOwner()
    local pVictim = pOfficer:GetEyeTrace().Entity

    self:SetNextSecondaryFire( CurTime() + 0.5 )

    if not self:CanCuff( pVictim ) then return end
    if not pVictim:IsHandcuffed() then return end

    if SERVER then
        -- @TODO Animation?

        pVictim:UnHandcuff()
    end

    -- @TODO: Consider different sound for uncuffing
    self.Weapon:EmitSound("rpthandcuffleftclick.mp3")
end