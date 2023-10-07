AddCSLuaFile()

-- Of course DEFINE_BASECLASS doesn't work on helix.
-- Fuck this shit, we're gonna be remaking the kernel sooner than we think.
DEFINE_BASECLASS( "prp_heist_base" )

ENT.Type            = "anim"
ENT.Base            = "prp_heist_base"

ENT.PrintName		= "Loot"
ENT.Author			= "sil"
ENT.Category        = "Palomino: Heists"
ENT.Purpose			= "Heists Plugin"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

-- @TODO: Change to a better button
ENT.Model           = "models/models/bkr_prop_bkr_cashpile_04.mdl"

ix.config.Add( "heistLootTime", 10, "Number of seconds it takes to grab money.", nil, {
    data = { min = 1, max = 30 },
    category = "Palomino: Heist"
} )

function ENT:Initialize()
    BaseClass.Initialize( self )

    timer.Simple( 0, function()
        self:SetMoney( 1000 )
    end )
end

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Money" )
end

function ENT:Use( pPlayer )
    if not IsValid( pPlayer ) then return end

    local iTime = ix.config.Get( "heistLootTime", 10 )

    pPlayer:SetAction( "Grabbing money...", iTime )
    pPlayer:DoStaredAction( self, function()
        SafeRemoveEntity( self )

        local iMoney = pPlayer:GetNW2Int( "PRP.Heist.Money", 0 )
        pPlayer:SetNW2Int( "PRP.Heist.Money", iMoney + self:GetMoney() )
    end, iTime, function()
        pPlayer:SetAction()
    end )
end