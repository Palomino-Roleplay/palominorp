AddCSLuaFile()

DEFINE_BASECLASS( "prp_heist_base" )

ENT.Type            = "anim"
ENT.Base            = "prp_heist_base"

ENT.PrintName		= "Terminal"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Heists"
ENT.Purpose			= "Heists Plugin"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

-- @TODO: Set this to something that makes more sense.
ENT.Model           = "models/props_combine/combine_interface001.mdl"

function ENT:Initialize()
    BaseClass.Initialize( self )
end