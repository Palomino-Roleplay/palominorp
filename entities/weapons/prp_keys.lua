AddCSLuaFile()

SWEP.PrintName = "Keys"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = true
SWEP.Category = "Palomino"
SWEP.Base = "weapon_base"

SWEP.Author = "Crap-Head & sil"
SWEP.Instructions = "Primary Fire: Lock\nSecondary Fire: Unlock"
SWEP.Purpose = "Hitting things and knocking on doors."
SWEP.Drop = false


SWEP.ViewTranslation = 4

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel 				= "models/craphead_scripts/adv_keys_2/c_key1.mdl"
SWEP.WorldModel 			= "models/craphead_scripts/adv_keys_2/w_key1.mdl"

SWEP.UseHands = true
SWEP.ViewModelFOV = 75
SWEP.ViewModelFlip = false

SWEP.PRP_WepSelectIcon = Material( "materials/prp/icons/weapons/keys.png" )

if SERVER then
	util.AddNetworkString( "PRP.Keys.Anim" )

	local function ADVWEP_LockUnlockAnim( ply )
		local RP = RecipientFilter()
		RP:AddAllPlayers()

		umsg.Start( "anim_keys", RP )
			umsg.Entity( ply )
			umsg.String( "usekeys" )
		umsg.End()

		ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true )
	end

	local function CH_Keys_PerformKnock( ply )
		ply:EmitSound( table.Random( CH_Keys.Config.DoorKnockSounds ), 100, math.random( 90, 110 ) )

		umsg.Start( "anim_keys" )
			umsg.Entity( ply )
			umsg.String( "knocking" )
		umsg.End()

		ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_HL2MP_GESTURE_RANGE_ATTACK_FIST, true )
	end
end

local function FormatViewModelAttachment(vOrigin, bFrom)

	local view = render.GetViewSetup()

	local vEyePos = view.origin
	local aEyesRot = view.angles
	local vOffset = vOrigin - vEyePos
	local vForward = aEyesRot:Forward()

	local nViewX = math.tan( view.fovviewmodel_unscaled * math.pi / 360)

	if (nViewX == 0) then
		vForward:Mul(vForward:Dot(vOffset))
		vEyePos:Add(vForward)

		return vEyePos
	end

	local nWorldX = math.tan( view.fov_unscaled * math.pi / 360)

	if (nWorldX == 0) then
		vForward:Mul(vForward:Dot(vOffset))
		vEyePos:Add(vForward)

		return vEyePos
	end

	local vRight = aEyesRot:Right()
	local vUp = aEyesRot:Up()

	if (bFrom) then
		local nFactor = nWorldX / nViewX
		vRight:Mul(vRight:Dot(vOffset) * nFactor)
		vUp:Mul(vUp:Dot(vOffset) * nFactor)
	else
		local nFactor = nViewX / nWorldX
		vRight:Mul(vRight:Dot(vOffset) * nFactor)
		vUp:Mul(vUp:Dot(vOffset) * nFactor)
	end

	vForward:Mul(vForward:Dot(vOffset))

	vEyePos:Add(vRight)
	vEyePos:Add(vUp)
	vEyePos:Add(vForward)

	return vEyePos
end

function SWEP:Holster()
	-- Remove keychain
	if IsValid( self.Keychain ) then
		self.Keychain:Remove()
	end

	if IsValid( self.WorldModel ) then
		self.WorldModel:Remove()
	end

	return true
end

function SWEP:Initialize()
	self:SetHoldType( "slam" )

	self:SetNextIdle( 0 )

	return true
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Float", 0, "NextIdle" )
	
	self:NetworkVar( "String", 0, "WModel" )
	self:NetworkVar( "String", 1, "Keychain" )
end




function SWEP:Deploy()
	local cur_time = CurTime()
	local ply = self:GetOwner()
	
	-- Setup the skin
	local vm = ply:GetViewModel()
	if not IsValid( vm ) then
		return
	end
	
	-- Change models
	self.EquippedKey = CH_Keys.Keys[ "door_key_3" ]
	vm:SetModel( self.EquippedKey.ViewModel )
	
	-- Set net vars
	self:SetWModel( self.EquippedKey.WorldModel )
	self:SetKeychain( "keychain_deathstar" )
	
	-- Change skin
	local equipped_skin = CH_Keys.Skins[ ply:CH_Keys_GetEquipped( "Skin" ) ]
	if equipped_skin then
		vm:SetSkin( equipped_skin.Skin )
		self:SetSkin( equipped_skin.Skin )
	end
	
	-- Draw animation
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextIdle( cur_time + self:SequenceDuration() )
	
	return true
end

-- @TODO: Have this be a general thing
function SWEP:DrawWeaponSelection( iX, iY, iWidth, iHeight, iAlpha )
    surface.SetDrawColor( 255, 255, 255, iAlpha )

    surface.SetMaterial( self.PRP_WepSelectIcon )
    surface.DrawTexturedRect(
        iX + ( iWidth - self.PRP_WepSelectIcon:Width() ) / 2,
        iY + ( iHeight - self.PRP_WepSelectIcon:Height() ) / 2,
        self.PRP_WepSelectIcon:Width(),
        self.PRP_WepSelectIcon:Height()
    )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )

	if not IsFirstTimePredicted() then return end

	local playback_rate = CH_Keys.Config.AnimationSpeed

	self:SendWeaponAnim( self.EquippedKey.Animations.Lock or ACT_VM_PRIMARYATTACK )
	self:GetOwner():GetViewModel():SetPlaybackRate( playback_rate )
	self:SetNextIdle( CurTime() + ( self:SequenceDuration() / playback_rate ) )
	
	self:SetNextPrimaryFire( CurTime() + ( self:SequenceDuration() / playback_rate ) )
	self:SetNextSecondaryFire( CurTime() + ( self:SequenceDuration() / playback_rate ) )

	if (CLIENT) then
		return
	end

	local data = {}
		data.start = self.Owner:GetShootPos()
		data.endpos = data.start + self.Owner:GetAimVector()*96
		data.filter = self.Owner
	local entity = util.TraceLine(data).Entity

	--[[
		Locks the entity if the contiditon fits:
			1. The entity is door and client has access to the door.
			2. The entity is vehicle and the "owner" variable is same as client's character ID.
	--]]
	if (IsValid(entity) and
		(
			(entity:IsDoor() and entity:CheckDoorAccess(self.Owner)) or
			(entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == self.Owner)
		)
	) then
		self:ToggleLock( entity, true )
	end
end

function SWEP:ToggleLock(door, state)
    if not IsValid(self.Owner) or self.Owner:GetPos():Distance(door:GetPos()) > 96 then
        return
    end

    local lockSound = "doors/door_latch1.wav"
    local unlockSound = "doors/door_latch3.wav"

	local action = state and "lock" or "unlock"

    if door:IsDoor() then
        local partner = door:GetDoorPartner()

        door:Fire(action)
        if IsValid(partner) then
			partner:Fire(action)
        end

        self.Owner:EmitSound(state and lockSound or unlockSound)
        hook.Run(state and "PlayerLockedDoor" or "PlayerUnlockedDoor", self.Owner, door, partner)

    elseif door:IsVehicle() then

		door:Fire(action)

        if door.IsSimfphyscar then
            door.IsLocked = state or nil
        end

        self.Owner:EmitSound(state and lockSound or unlockSound)
        hook.Run(state and "PlayerLockedVehicle" or "PlayerUnlockedVehicle", self.Owner, door)
    end
end

function SWEP:SecondaryAttack()
	local time = ix.config.Get("doorLockTime", 1)
	local time2 = math.max(time, 1)

	self:SetNextPrimaryFire(CurTime() + time2)
	self:SetNextSecondaryFire(CurTime() + time2)

	if (!IsFirstTimePredicted()) then
		return
	end

	if (CLIENT) then
		return
	end

	local data = {}
		data.start = self.Owner:GetShootPos()
		data.endpos = data.start + self.Owner:GetAimVector()*96
		data.filter = self.Owner
	local entity = util.TraceLine(data).Entity



	if (IsValid(entity) and
		(
			(entity:IsDoor() and entity:CheckDoorAccess(self.Owner)) or
			(entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == self.Owner)
		)
	) then
		self.Owner:SetAction("@unlocking", time, function()
			self:ToggleLock(entity, false)
		end)

		return
	end
end

function SWEP:ViewModelDrawn()
	local ply = self:GetOwner()
	local vm = ply:GetViewModel()
	if not IsValid( vm ) then
		return
	end

	local obj = vm:LookupAttachment( "dongle" )
	local equipped_keychain = CH_Keys.Keychains[ self:GetKeychain() ]
	if not equipped_keychain then
		return
	end

	if obj then		
		local muzzle = vm:GetAttachment( obj )
		local pos = muzzle.Pos
		local ang = muzzle.Ang
		
		local offset = equipped_keychain.Offset
		if offset then
			if offset.Up then
				pos = pos + ang:Up() * offset.Up
			end
			if offset.Right then
				pos = pos + ang:Right() * offset.Right
			end
			if offset.Forward then
				pos = pos + ang:Forward() * offset.Forward
			end
		end

		if not IsValid( self.Keychain ) then
			self.Keychain = ClientsideModel( equipped_keychain.Model )
			self.Keychain:SetPos( FormatViewModelAttachment( pos, false ) )
			self.Keychain:SetAngles( ang )
			self.Keychain:SetParent( self )
			self.Keychain:SetModelScale( equipped_keychain.Scale )
			self.Keychain:SetSkin( equipped_keychain.Skin )
			self.Keychain:SetNoDraw( true )
		else
			self.Keychain:SetPos( FormatViewModelAttachment( pos, false ) )
			self.Keychain:SetAngles( ang )
		end
	end
	
	render.SetColorModulation( color_white.r / 255, color_white.g / 255, color_white.b / 255 )
	render.SetBlend( color_white.a / 255 )
	
	self.Keychain:DrawModel()
	
	render.SetBlend( 1 )
	render.SetColorModulation( 1, 1, 1 )
end

if CLIENT then
	function SWEP:DrawWorldModel()
		-- Create the world model if not exists
		if not IsValid( self.WorldModel ) then
			self.WorldModel = ClientsideModel( self:GetWModel() )
		end
		
		local ply = self:GetOwner()
		
		-- Apply skin
		local vm = ply:GetViewModel()
		if IsValid( vm ) then
			self.WorldModel:SetSkin( vm:GetSkin() )
		end
		
		-- Draw it
		self.WorldModel:SetNoDraw( true )

		if IsValid( ply ) then
			-- Specify a good position
			local offsetVec = Vector( 4.5, -2.2, 0 )
			local offsetAng = Angle( 149, 100, 0 )
			
			local boneid = ply:LookupBone( "ValveBiped.Bip01_R_Hand" ) -- Right Hand
			if not boneid then return end

			local matrix = ply:GetBoneMatrix( boneid )
			if not matrix then return end

			local pos, ang = LocalToWorld( offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles() )

			self.WorldModel:SetPos( pos )
			self.WorldModel:SetAngles( ang )

			self.WorldModel:SetupBones()
		else
			self.WorldModel:SetPos( self:GetPos() )
			self.WorldModel:SetAngles( self:GetAngles() )
		end

		self.WorldModel:DrawModel()
		
		-- Keychain
		local obj = self.WorldModel:LookupAttachment( "dongle" )
		local equipped_keychain = CH_Keys.Keychains[ self:GetKeychain() ]
		if not equipped_keychain then
			return
		end

		if obj then		
			local muzzle = self.WorldModel:GetAttachment( obj )
			local pos = muzzle.Pos
			local ang = muzzle.Ang
			
			local offset = equipped_keychain.Offset
			if offset then
				if offset.Up then
					pos = pos + ang:Up() * offset.Up
				end
				if offset.Right then
					pos = pos + ang:Right() * offset.Right
				end
				if offset.Forward then
					pos = pos + ang:Forward() * offset.Forward
				end
			end
			
			if not IsValid( self.Keychain ) then			
				self.Keychain = ClientsideModel( equipped_keychain.Model )
				self.Keychain:SetPos( pos )
				self.Keychain:SetAngles( ang )
				self.Keychain:SetParent( self )
				self.Keychain:SetModelScale( equipped_keychain.Scale )
				self.Keychain:SetSkin( equipped_keychain.Skin )
				self.Keychain:SetNoDraw( true )
			else
				self.Keychain:SetPos( pos )
				self.Keychain:SetAngles( ang )
			end
		end
		
		render.SetColorModulation( color_white.r / 255, color_white.g / 255, color_white.b / 255 )
		render.SetBlend( color_white.a / 255 )
		
		self.Keychain:DrawModel()
		
		render.SetBlend( 1 )
		render.SetColorModulation( 1, 1, 1 )
	end
end