AddCSLuaFile()

DEFINE_BASECLASS( "prp_heist_base" )

ENT.Type            = "anim"
ENT.Base            = "prp_heist_base"

ENT.PrintName		= "Gas Canister"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Heists"
ENT.Purpose			= "Heists Plugin"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

-- @TODO: Change to a better button
ENT.Model           = "models/props_junk/PropaneCanister001a.mdl"

function ENT:Initialize()
    BaseClass.Initialize( self )

    self.lastEmit = 0
end

function ENT:OnRemove()
    if IsValid( self.emitter ) then
        self.emitter:Finish()
    end

    if self.sound then
        self:StopLoopingSound( self.sound )
    end
end

function ENT:Use( pPlayer )
    if self:GetNetVar( "emitting", false ) then
        self:SetNetVar( "emitting", false )
        if self.sound then self:StopLoopingSound( self.sound ) end
        return
    end

    self:SetNetVar( "emitting", true )
    self:SetNetVar( "emitStart", CurTime() )
    self.sound = self:StartLoopingSound( "ambient/gas/steam2.wav" )
end

local tLaserZone = {
    min = Vector( -554, 2592, -104 ),
    max = Vector( -434, 3300, -17 ),
}

local tSecureZone = {
    min = Vector( -386, 2560, -103 ),
    max = Vector( -609, 2400, -64 ),
}

local function EmitLaserSmoke( eEntity, oEmitter )
    local iStartTime = eEntity:GetNetVar( "emitStart", 0 )
    local iMultiplier = math.Clamp( ( CurTime() - iStartTime ) / ix.config.Get( "gasPropagateTime", 30 ), 0, 1 )

    local vPos
    local vVentPos
    local iSuckMultiplierDenominator
    if math.random() < 0.15 then
        iSuckMultiplierDenominator = 350
        vVentPos = Vector( -384, 2504, -10 )
        vPos = Vector(
            math.Rand( tSecureZone.min.x, tSecureZone.max.x ),
            math.Rand( tSecureZone.min.y, tSecureZone.max.y ),
            math.Rand( tSecureZone.min.z, tSecureZone.min.z + iMultiplier * ( tSecureZone.max.z - tSecureZone.min.z ) )
        )
    else
        iSuckMultiplierDenominator = 1000
        vVentPos = Vector( -496, 3368, -7 )
        vPos = Vector(
            math.Rand( tLaserZone.min.x, tLaserZone.max.x ),
            math.Rand( tLaserZone.min.y, tLaserZone.min.y + iMultiplier * ( tLaserZone.max.y - tLaserZone.min.y ) ),
            math.Rand( tLaserZone.min.z, tLaserZone.min.z + iMultiplier * ( tLaserZone.max.z - tLaserZone.min.z ) )
        )
    end

    local vDir = ( vVentPos - vPos ):GetNormalized()
    local iDistance = vPos:Distance( vVentPos )

    -- The closer the particle is to the vent, the stronger it gets sucked.
    local iSuckMultiplier = math.Clamp( 1 - ( iDistance / iSuckMultiplierDenominator ), 0, 1 )
    iSuckMultiplier = iSuckMultiplier * iSuckMultiplier
    local iSuckMultiplierInverse = 1 - iSuckMultiplier
    local iSuckMultiplierInverseClamped = math.Clamp( iSuckMultiplierInverse, 0.25, 1 )

    local particle = oEmitter:Add( string.format( "particle/smokesprites_%04d", math.random( 1, 16 ) ), vPos, false )
    particle:SetDieTime( 5 * iSuckMultiplierInverse )
    particle:SetStartAlpha( 32 * iMultiplier * iSuckMultiplierInverseClamped )
    particle:SetEndAlpha( 0 )
    particle:SetStartSize( 50 * iMultiplier * iSuckMultiplierInverseClamped )
    particle:SetEndSize( 150 * iSuckMultiplierInverse )
    particle:SetRoll( math.Rand( 0, 360 ) )
    particle:SetRollDelta( math.Rand( -1, 1 ) )
    particle:SetColor( 128, 128, 148 )
    particle:SetGravity( Vector( 0, 0, 5 ) )
    particle:SetVelocity( ( vDir * iSuckMultiplier * 250 ) + VectorRand() * 10 )
    particle:SetCollide( true )
end

if CLIENT then
    function ENT:Think()
        if self:GetNetVar( "emitting", false ) then
            if not IsValid( self.emitter ) then
                self.emitter = ParticleEmitter( self:GetPos() )
            end

            if self.lastEmit + 0.01 > CurTime() then return end

            local particle = self.emitter:Add( string.format( "particle/smokesprites_%04d", math.random( 1, 16 ) ), self:GetPos() + self:GetUp() * 9, false )
            particle:SetVelocity( VectorRand() * 10 )
            particle:SetDieTime( 0.3 )
            particle:SetStartAlpha( 32 )
            particle:SetEndAlpha( 0 )
            particle:SetStartSize( 0 )
            particle:SetEndSize( 32 )
            particle:SetRoll( math.Rand( 0, 360 ) )
            particle:SetRollDelta( math.Rand( -2, 2 ) )
            particle:SetColor( 128, 128, 148 )
            particle:SetGravity( Vector( 0, 0, 100 ) )
            particle:SetVelocity( self:GetUp() * 175 )
            particle:SetCollide( false )
            particle:SetAirResistance( 128 )

            EmitLaserSmoke( self, self.emitter )

            self.lastEmit = CurTime()
        else
            if IsValid( self.emitter ) then
                self.emitter:Finish()
            end
        end
    end
end