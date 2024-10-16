SWEP.PrintName              = "Drying Rack"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to find out"
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

SWEP.ViewModel			    = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel			    = "models/zerochain/props_growop2/zgo2_dryline.mdl"
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:Initialize()
    self:SetHoldType("revolver")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local pPlayer = self:GetOwner()
    local tTrace = pPlayer:GetEyeTrace()

    local vStart = tTrace.HitPos
    local vNormal = tTrace.HitNormal

    local eEntity = ents.Create( "zgo2_dryline" )
    eEntity:SetPos( vStart )
    eEntity:SetAngles( vNormal:Angle() + Angle( 90, 0, 0 ) )
    eEntity:SetWallEndAngle( vNormal:Angle() + Angle( 90, 0, 0 ) )

    eEntity:Spawn()
    eEntity:Activate()

    eEntity:SetWallAngle( vNormal:Angle() )

    eEntity:EmitSound("weapons/crossbow/hit1.wav")

    zclib.Player.SetOwner( eEntity, pPlayer )

    self:GetOwner():StripWeapon( self:GetClass() )
end

function SWEP:SecondaryAttack()
    return
end