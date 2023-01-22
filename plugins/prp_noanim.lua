local PLUGIN = PLUGIN

PLUGIN.name = "No Animation"
PLUGIN.author = "sil"
PLUGIN.description = "Remove's helix's ugly character animations"

local GAMEMODE_BASE = baseclass.Get( "gamemode_base" )

function Schema:TranslateActivity( pPlayer, iAct )
    return GAMEMODE_BASE:TranslateActivity( pPlayer, iAct )
end

function Schema:DoAnimationEvent( pPlayer, event, data )
    return GAMEMODE_BASE:DoAnimationEvent( pPlayer, event, data )
end

-- function Schema:PlayerWeaponChanged( pPlayer, pOldWeapon, pNewWeapon )
--     if CLIENT then return end
--     pPlayer:SetWepRaised( true, pNewWeapon )
-- end

function Schema:PlayerModelChanged()
    return false
end

function Schema:PlayerEnteredVehicle()
    return false
end

function Schema:PlayerLeaveVehicle()
    return false
end