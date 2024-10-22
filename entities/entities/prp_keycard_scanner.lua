AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName		= "Keycard Scanner"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Heists Plugin"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( self.Model or "models/alyxintprops/keycard_reader_001_0.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

        self:PhysWake()

        self:GetPhysicsObject():EnableMotion( false )

        self:SetUseType( SIMPLE_USE )
    end

end

AccessorFunc( ENT, "m_tDoors", "Doors" )

function ENT:GetAccess( cCharacter )
    return cCharacter:IsGovernment()
end

function ENT:Use( pPlayer )
    if not IsValid( pPlayer ) then return end

    local tDoors = self:GetDoors()
    if not tDoors then return end

    if not pPlayer:GetCharacter() then return end
    if not self:GetAccess( pPlayer:GetCharacter() ) then
        if not self.m_iSoundCooldown or self.m_iSoundCooldown < CurTime() then
            self:EmitSound( "buttons/button8.wav" )
            self.m_iSoundCooldown = CurTime() + 2
        end

        return
    end

    self:EmitSound( "buttons/button24.wav" )

    for _, eDoor in ipairs( tDoors ) do
        if not IsValid( eDoor ) then continue end

        eDoor:Fire( "Unlock" )
        eDoor:Fire( "Open" )

        eDoor:Fire( "Close", "", 4 )
        eDoor:Fire( "Lock", "", 4 )
    end
end