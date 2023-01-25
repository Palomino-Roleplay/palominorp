SWEP.PrintName              = "Restrained"
SWEP.Author                 = "Kobralost & sil"
SWEP.Instructions           = "You can't break those cuffs."
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

SWEP.ViewModel = Model( "models/realistic_police/handcuffs/w_deploy_handcuffs.mdl" )
SWEP.WorldModel = Model("models/realistic_police/handcuffs/w_deploy_handcuffs.mdl")
SWEP.ViewModelFOV           = 80
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:PrimaryAttack()
	
end 

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
	-- @TODO: Check out https://github.com/Facepunch/garrysmod-issues/issues/5148

	local pPlayer = self:GetOwner()
	for k,v in pairs(Realistic_Police.ManipulateBoneCuffed) do
		local bone = pPlayer:LookupBone(k)
		if bone then
			pPlayer:ManipulateBoneAngles(bone, v)
		end
	end

	self:SetHoldType("passive")
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end

	Realistic_Police.ResetBonePosition(Realistic_Police.ManipulateBoneCuffed, self:GetOwner())

	return false
end

if CLIENT then
	local WorldModel = ClientsideModel(SWEP.WorldModel)

	WorldModel:SetSkin(1)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local _Owner = self:GetOwner()

		if (IsValid(_Owner)) then

			local offsetVec = Vector(5, 1, -9)
			local offsetAng = Angle(190, 140, -20)
			
			local boneid = _Owner:LookupBone("ValveBiped.Bip01_R_Hand")
			if !boneid then return end

			local matrix = _Owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)
            WorldModel:SetupBones()
		else
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
		end

		WorldModel:DrawModel()
	end
	WorldModel:SetModelScale( WorldModel:GetModelScale() * 1.3, 0 )

	-- @TODO: Draw something on the HUD
	function SWEP:DrawHUD()
		return
	end

	function SWEP:GetViewModelPosition( vEyePos, aEyeAng )
		local vModelPos = vEyePos
		local aModelAng = aEyeAng

		vModelPos = vModelPos + aEyeAng:Right() * 4
		vModelPos = vModelPos + aEyeAng:Forward() * 10
		vModelPos = vModelPos + aEyeAng:Up() * -9.5

		aModelAng:RotateAroundAxis( aEyeAng:Right(), 50 )
		aModelAng:RotateAroundAxis( aEyeAng:Up(), -20 )
		aModelAng:RotateAroundAxis( aEyeAng:Forward(), 70 )

		return vModelPos, aModelAng
	end
end