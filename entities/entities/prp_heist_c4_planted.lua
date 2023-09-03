AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName		= "C4"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Heists"
ENT.Purpose			= "Testbench"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

ENT.Positions = {
	["rp_southside_day"] = {
		["vault_floor"] = {
			pos = Vector( -1801, 3191, -274 )
		}
	}
}

if SERVER then
	util.AddNetworkString( "PRP.Heists.Explode.Close" )
	util.AddNetworkString( "PRP.Heists.Explode.Far" )
end

-- Cool lock burning thing
-- game.AddParticles("particles/c4_train_ground_effect.pcf")

if CLIENT then
    game.AddParticles("particles/explosion_hegrenade_interior.pcf")
    game.AddParticles("particles/explosion_basic.pcf")
    game.AddParticles("particles/explosion_hegrenade_dirt_fallback.pcf")
    game.AddParticles("particles/explosion_smokegrenade_fallback.pcf")
    PrecacheParticleSystem( "explosion_hegrenade_interior" )
    PrecacheParticleSystem( "explosion_basic" )
    PrecacheParticleSystem( "explosion_hegrenade_dirt_fallback" )
    PrecacheParticleSystem( "explosion_smokegrenade_fallback" )
end

local iSouthsideVaultFloorID = 4171

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )

	-- Init physics only on server, so it doesn't mess up physgun beam
	-- if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end

	-- Make prop to fall on spawn
	-- self:PhysWake()

	-- self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )

	if CLIENT then return end

	self:EmitSound( "weapons/c4/c4_plant_quiet.wav" )

	local iSecondsElapsed = 0
	local iSecondsToExplosion = 3
	timer.Create( "Explode_" .. self:EntIndex(), 1, iSecondsToExplosion, function()
		iSecondsElapsed = iSecondsElapsed + 1

		if iSecondsElapsed >= iSecondsToExplosion then
			self:Explode( self:GetPos() )
		else
			self:EmitSound( "weapons/c4/c4_beep3.wav" )
		end
	end )
end

function ENT:OnRemove()
	if CLIENT then
		for _, oEffect in pairs( self.effects ) do
			oEffect:StopEmissionAndDestroyImmediately()
		end
	end

	timer.Remove( "Explode_" .. self:EntIndex() )
end

function ENT:Explode( sPosition )
	print( "Exploding" )
	-- self:EmitSound( "weapons/c4/c4_explode1.wav", SNDLVL_150dB, 100, 1, CHAN_AUTO, 0, 1 )

	-- @TODO: Setup custom positions
	local oRecipientsClose = RecipientFilter()
	oRecipientsClose:AddPVS( self:GetPos() )

	local oRecipientsFar = RecipientFilter()
	oRecipientsFar:AddPAS( self:GetPos() )
	oRecipientsFar:RemovePVS( self:GetPos() )

	net.Start( "PRP.Heists.Explode.Close" )
		net.WriteEntity( self )
	net.Send( oRecipientsClose )

	net.Start( "PRP.Heists.Explode.Far" )
		net.WriteEntity( self )
	net.Send( oRecipientsFar )

	local eVaultFloor = ents.GetMapCreatedEntity( iSouthsideVaultFloorID )
	-- SafeRemoveEntity( eVaultFloor )

	-- SafeRemoveEntity( self )

	-- BankAlarmStart()

	timer.Simple( 4, function()
		-- game.CleanUpMap()
	end )
end

local tBankSmokePos = {
    hallway = {
        min = Vector( -1430, 3124, -280 ),
        max = Vector( -1692, 3256, -168 ),
    }
}

function ENT:ExplodeEffects()
	-- local oExplosionEffect1 = self:CreateParticleEffect( "explosion_hegrenade_interior" )
	-- local oExplosionEffect2 = self:CreateParticleEffect( "explosion_basic" )
	-- local oExplosionEffect3 = self:CreateParticleEffect( "explosion_hegrenade_dirt_fallback" )

	local tBankSmokePositions = {
		Vector( -1821.285278, 3425.223633, -279 ),
		Vector( -1824.718994, 3200.252686, -279 ),
		Vector( -1827.366821, 3027.775391, -279 ),
		Vector( -1612.470703, 3187.799072, -279 ),
		-- Vector( -1541.513550, 3195.569336, -279 ),
		Vector( -1798.177979, 3181.374512, -438.585205 ),
		Vector( -1453.757568, 3191.417725, -279 )
	}

	self.effects = {}

	-- for _, vPosition in pairs( tBankSmokePositions or {} ) do
	-- 	-- @TODO: It seems it might not be drawing when the position is not in view. We should render this manually with :Render().
	-- 	local oSmokeEffect = CreateParticleSystem( self, "explosion_smokegrenade_fallback", PATTACH_ABSORIGIN, 0, self:WorldToLocal( vPosition ) )
	-- 	oSmokeEffect:SetShouldDraw( true )
	-- 	oSmokeEffect:StartEmission()
	-- 	oSmokeEffect:SetSortOrigin( vPosition )

	-- 	table.insert( self.effects, oSmokeEffect )
	-- end

	self:EmitSound( "weapons/c4/c4_explode1.wav", 150, 100, 1, CHAN_AUTO, 0, 1 )
end

function ENT:ExplodeClose()
	print( "Close Explosion" )
	self:ExplodeEffects()

	util.ScreenShake( self:GetPos(), 25, 15, 2, 1000 )
end

function ENT:ExplodeFar()
	print( "Far Explosion" )
end

net.Receive( "PRP.Heists.Explode.Far", function()
	local eEntity = net.ReadEntity()
	eEntity:ExplodeFar()
end )

net.Receive( "PRP.Heists.Explode.Close", function()
	local eEntity = net.ReadEntity()
	eEntity:ExplodeClose()
end )