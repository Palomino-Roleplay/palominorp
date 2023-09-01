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

function ENT:Use( pPlayer )
    if not IsValid( pPlayer ) then return end

    self:EmitSound( "buttons/combine_button1.wav" )

    local iHackTime = ix.config.Get( "terminalHackTime", 30 )

    pPlayer:SetAction( "Hacking...", iHackTime )
    pPlayer:DoStaredAction(
        self,
        function()
            self:Success()
        end,
        iHackTime,
        function()
            -- self:Failure()
            pPlayer:SetAction( nil )
            self:EmitSound( "buttons/combine_button_locked.wav" )
        end
    )
end

function ENT:Success()
    self:EmitSound( "buttons/combine_button7.wav" )
    self:OnSuccess()
end

function ENT:Failure()
    self:OnFailure()
end

function ENT:OnSuccess()
end

function ENT:OnFailure()
end