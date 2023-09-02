ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName		= "Banking Locker"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= ""
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:Initialize()
    -- Sets what model to use
    self:SetModel( "models/items/ammocrate_ar2.mdl" )

    -- Physics stuff
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    -- Init physics only on server, so it doesn't mess up physgun beam
    if ( SERVER ) then self:PhysicsInit( SOLID_VPHYSICS ) end

    -- Make prop to fall on spawn
    self:PhysWake()

    if SERVER then self:SetUseType( SIMPLE_USE ) end
end

function ENT:Use( pPlayer )
    if not IsValid( pPlayer ) then return end
    if not pPlayer:IsPlayer() then return end
    if not pPlayer:GetCharacter() then return end
    local cCharacter = pPlayer:GetCharacter()

    PRP.Banking.Open( cCharacter )
end