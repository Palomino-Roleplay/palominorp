SWEP.PrintName              = "Lockpick"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to lockpick"
SWEP.Category               = "Palomino"

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

SWEP.ViewModel			    = "models/lockpeek/c_screwdriver.mdl"
SWEP.WorldModel			    = "models/lockpeek/w_screwdriver.mdl"
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:Initialize()
    self:SetHoldType("normal")
end