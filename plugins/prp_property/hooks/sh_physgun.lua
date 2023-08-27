local PLUGIN = PLUGIN;

PRP = PRP or {}
PRP.Property = PRP.Property or {}

function PLUGIN:PhysgunPickup( pPlayer, eEntity )
    -- @TODO: Allow staff to move stuff and such.
    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassPhysgunLimits" ) then return true end

    -- @TODO: There has to be a better way to do this.
    if eEntity:GetNWString( "PRP.Prop.SpawnerSteamID", "" ) == pPlayer:SteamID() then
        return true
    end

    return false
end

function PLUGIN:OnPhysgunFreeze( eWeapon, oPhysics, eEntity, pPlayer )
    -- if pPlayer:IsAdmin() then return end
    if not IsValid( eEntity ) then return end

    return false
end