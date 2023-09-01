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
end