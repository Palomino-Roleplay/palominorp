SWEP.PrintName              = "Lockpick"
SWEP.Author                 = "sil"
SWEP.Instructions           = "A tool LithuanianSil & Tenrys made."
SWEP.Category               = "Palomino"

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= 10
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.ViewModel			    = "models/lockpeek/c_screwdriver.mdl"
SWEP.WorldModel			    = "models/lockpeek/w_screwdriver.mdl"
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    self:SetNextPrimaryFire( CurTime() + 1 )

    local pPlayer = self:GetOwner()
    if not IsValid( pPlayer ) then return end

    local tTrace = pPlayer:GetEyeTrace()
    if not IsValid( tTrace.Entity ) or not tTrace.Entity:IsDoor() then return end

    Print( "running da hook" )

    hook.Run( "lockpickStarted", pPlayer, tTrace.Entity, tTrace )
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Succeed()
    if CLIENT then return end

    local pPlayer = self:GetOwner()
    if not IsValid( pPlayer ) then return end

    local tTrace = pPlayer:GetEyeTrace()
    if not IsValid( tTrace.Entity ) or not tTrace.Entity:IsDoor() then return end

    local eDoor = self:GetOwner().lockpeekDoor

    if not IsValid( eDoor ) then return end
    eDoor:Fire( "unlock" )
end

function SWEP:Fail()
    return
end

function SWEP:GetIsLockpicking()
    return self:GetOwner().lockpeekDoor ~= nil
end