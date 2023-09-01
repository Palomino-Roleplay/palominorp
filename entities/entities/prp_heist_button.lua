AddCSLuaFile()

-- Of course DEFINE_BASECLASS doesn't work on helix.
-- Fuck this shit, we're gonna be remaking the kernel sooner than we think.
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

-- @TODO: Change to a better button
ENT.Model           = "models/maxofs2d/button_02.mdl"

function ENT:Initialize()
    BaseClass.Initialize( self )
end