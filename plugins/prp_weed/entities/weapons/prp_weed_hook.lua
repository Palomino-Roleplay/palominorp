SWEP.PrintName              = "Drying Rack"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to find out"
SWEP.Category               = "Palomino: Development"

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

SWEP.ViewModel			    = "models/weapons/c_rpg.mdl"
SWEP.WorldModel			    = "models/weapons/w_rocket_launcher.mdl"
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:Initialize()
    -- @TODO: Whatever the fuck it's gonna be
    self:SetHoldType("rpg")
end

-- @TODO: Figure out a way to only create a PostDrawTranslucentRenderables
hook.Add( "PostDrawTranslucentRenderables", "PRP.WeedHook.PostDrawTranslucentRenderables", function()
    -- @TODO
end )

