local PLUGIN = PLUGIN

PRP = PRP or {}
PRP.Property = PRP.Property or {}
PRP.Prop = PRP.Prop or {}

util.AddNetworkString( "PRP.Prop.Spawn" )

function PRP.Prop.Spawn( pPlayer, sCategoryID, sModel )
    -- @TODO: Hell no.
    -- @TODO: Alive check, isn't handcuffed check, etc.

    if not pPlayer:GetCharacter() then return end
    local cCharacter = pPlayer:GetCharacter()

    local iCooldown = ix.config.Get( "propertySpawnmenuCooldown", 1 )

    if pPlayer.m_iLastPropSpawn and pPlayer.m_iLastPropSpawn > CurTime() then
        return false, "You must wait " .. math.ceil( pPlayer.m_iLastPropSpawn - CurTime() ) .. " seconds before using the spawnmenu again."
    end
    pPlayer.m_iLastPropSpawn = CurTime() + iCooldown

    local oCategory = PRP.Prop.Category.Get( sCategoryID )

    -- Print( tCategory )

    if not oCategory then
        -- @TODO: Auto-bug reporting for stuff like this would be rly cool.
        return false, "INTERNAL ERROR: Category does not exist."
    end

    if not oCategory:HasModel(sModel) then
        -- @TODO: Actually, for some of this stuff, I'd trigger an exploit alert...
        return false, "INTERNAL ERROR: Model does not exist in category."
    end

    local tModelConfig = oCategory:GetModel( sModel ).cfg

    -- @TODO: Base this on properties player has *access* to.
    local tProperties = cCharacter:GetRentedProperties()
    local oProperty = nil
    for _, oPropertyCandidate in pairs( tProperties ) do
        if oPropertyCandidate:Contains( pPlayer:GetPos() ) then
            oProperty = oPropertyCandidate
            break
        end
    end

    if not oProperty then
        return false, "You must be inside your rented property to spawn a prop."
    end

    local tTrace = util.TraceLine( {
        start = pPlayer:GetShootPos(),
        endpos = pPlayer:GetShootPos() + pPlayer:GetAimVector() * 300,
        filter = pPlayer
    } )

    if not tTrace.Hit then
        return false, "You must be looking at a nearby surface to spawn a prop."
    end

    if not oProperty:Contains( tTrace.HitPos ) then
        return false, "You cannot spawn props outside your property."
    end

    -- @TODO: Make sure sandbox aint doing some fucky shit in this function
    local eProp = DoPlayerEntitySpawn( pPlayer, "prop_physics", sModel, tModelConfig.skin or 0, tModelConfig.bodygroups or nil )

    -- Check again *just* in case (sandbox changes some positions on spawn.)
    if not oProperty:Contains( eProp:GetPos() ) then
        eProp:Remove()
        return false, "You may only spawn props inside your property."
    end

    -- hook.Run( "PlayerSpawnedProp", pPlayer, sModel, eProp )

    -- @TODO: Allow this for all categories (and maybe do them in a better way)
    oCategory:CallHook( "OnSpawn", eProp, pPlayer, sModel, tModelConfig )

    eProp.PhysgunDrop = function( pHookPlayer, eHookEntity )
        oCategory:CallHook( "PhysgunDrop", pHookPlayer, eHookEntity )
    end

    -- @TODO: We can definitely do our own networking here somehow
    eProp:SetCategory( oCategory )
    eProp:SetNWString( "PRP.Prop.SpawnerSteamID", pPlayer:SteamID() )

    oProperty:AddProp( eProp )

    return true
end

net.Receive( "PRP.Prop.Spawn", function( _, pPlayer )
    local sCategoryID = net.ReadString()
    local sModel = net.ReadString()

    local bSuccess, sFailureMessage = PRP.Prop.Spawn( pPlayer, sCategoryID, sModel )

    if not bSuccess then
        pPlayer:Notify( sFailureMessage )
    end
end )