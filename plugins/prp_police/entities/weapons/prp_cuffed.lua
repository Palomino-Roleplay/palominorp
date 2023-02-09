SWEP.PrintName              = "Restrained"
SWEP.Author                 = "Kobralost & sil"
SWEP.Instructions           = "You can't break those cuffs."
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

SWEP.ViewModel = Model( "models/realistic_police/handcuffs/w_deploy_handcuffs.mdl" )
SWEP.WorldModel = Model("models/realistic_police/handcuffs/w_deploy_handcuffs.mdl")
SWEP.ViewModelFOV           = 80
SWEP.UseHands               = true

SWEP.DrawAmmo               = false
SWEP.HoldType			   = "passive"

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

-- From realistic police mod
function SWEP:Deploy()
	self:SetHoldType( self.HoldType )

	local pPlayer = self:GetOwner()

	if not IsFirstTimePredicted() then return end
	if SERVER then return end
	timer.Simple( 0, function()
		for k,v in pairs(Realistic_Police.ManipulateBoneCuffed) do
		local bone = pPlayer:LookupBone(k)
			if bone then
				print("bonez")
				print(bone, v)
				pPlayer:ManipulateBoneAngles(bone, v)
			end
		end
	end )
	pPlayer._bCuffedBones = true

	return false
end 

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
	if SERVER then return end

	local pPlayer = self:GetOwner()
	timer.Simple( 0, function()
		if not IsValid( pPlayer ) then return end
		if not pPlayer._bCuffedBones then return end

		Realistic_Police.ResetBonePosition(Realistic_Police.ManipulateBoneCuffed, pPlayer )
	end )
end

-- Can't do on Holster because we return false to prevent holstering
hook.Add( "PlayerWeaponChanged", "PRP.Police.Cuffed.PlayerWeaponChanged", function( pPlayer, wNewWeapon )
	if SERVER then return end

	if pPlayer._bCuffedBones and ( not IsValid( wNewWeapon ) or wNewWeapon:GetClass() ~= "prp_cuffed" ) then
		Realistic_Police.ResetBonePosition(Realistic_Police.ManipulateBoneCuffed, pPlayer)
		pPlayer._bCuffedBones = false
	elseif not pPlayer._bCuffedBones and IsValid( wNewWeapon ) and wNewWeapon:GetClass() == "prp_cuffed" then
		timer.Simple(0, function()
			if not IsValid( pPlayer ) then return end
			if pPlayer._bCuffedBones then return end

			-- @TODO: Consolidate into a function
			for k,v in pairs(Realistic_Police.ManipulateBoneCuffed) do
				local bone = pPlayer:LookupBone(k)
				if bone then
					pPlayer:ManipulateBoneAngles(bone, v, true)
				end
			end

			wNewWeapon:SetHoldType( "passive" )

			pPlayer._bCuffedBones = true
		end )
	end
end )

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