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

        pPlayer:AddLoot( self:GetMoney(), "bank" )
    end, iTime, function()
        pPlayer:SetAction()
    end )
end

-- @TODO: Move to UI module
hook.Add( "HUDPaint", "PRP.Heists.Loot.HUDPaint", function()
    local oBank = PRP.Heist.Get( "bank" )
    local iLoot = LocalPlayer():GetNW2Int( "PRP.Heist.Loot", 0 )

    if not oBank or not oBank:GetPos() then return end
    if not iLoot or iLoot == 0 then return end

    local bNear = LocalPlayer():GetPos():DistToSqr( oBank:GetPos() ) < 15000000

    draw.SimpleText( "Loot: " .. iLoot, "DebugOverlay", ScrW() * 0.5, ScrH() * 0.95, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( "Near Bank: " .. tostring( bNear ), "DebugOverlay", ScrW() * 0.5, ScrH() * 0.95 + 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    if not LocalPlayer():GetLocalVar( "PRP.Heist.Safe", 0 ) then return end
    local iSecondsUntilLootGet = math.max( LocalPlayer():GetLocalVar( "PRP.Heist.Safe", 0 ) - CurTime(), 0 )
    local sTimer = string.FormattedTime( iSecondsUntilLootGet, "%02i:%02i" )
    draw.SimpleText( "Timer: " .. sTimer, "DebugOverlay", ScrW() * 0.5, ScrH() * 0.95 + 28, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end )