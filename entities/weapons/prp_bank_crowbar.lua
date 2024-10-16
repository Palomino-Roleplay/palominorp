AddCSLuaFile()

SWEP.PrintName              = "Crowbar"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to find out"
SWEP.Category               = "Palomino: Heists"

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

SWEP.ViewModel			    = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel			    = "models/weapons/w_crowbar.mdl"
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:Initialize()
    self:SetHoldType("melee")
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    self:SetNextPrimaryFire(CurTime() + 0.5)

    if CLIENT then return end

    local eEntity = self:GetOwner():GetEyeTrace().Entity

    if not IsValid(eEntity) then return end
    if not eEntity:CreatedByMap() then return end
    if eEntity:MapCreationID() != 3167 then return end

    eEntity:Fire("unlock")
    eEntity:Fire("open")

    self:GetOwner():EmitSound("doors/door_latch3.wav")
end