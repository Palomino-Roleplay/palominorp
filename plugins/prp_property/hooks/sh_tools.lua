local PLUGIN = PLUGIN

PRP = PRP or {}
PRP.Property = PRP.Property or {}
PRP.Property.Tools = PRP.Property.Tools or {}

PRP.Property.Tools.Global = {
    remover = true,
}

-- Whitelist per-model/subcategory/category in the prop config.
PRP.Property.Tools.Situational = {
    material = true,
    colour = true,
}

PRP.Property.Tools.Premium = {
    light = true,
    wheel = true,
    button = true,
    rope = true,
}

PRP.Property.Tools.Blacklist = {
    duplicator = true,
}

-- @TODO: Remove the debug prints in here.
function PLUGIN:CanTool( pPlayer, tTrace, sToolName, tTool, iButton )
    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassToolLimitsDangerous", nil ) then return true end

    local cCharacter = pPlayer:GetCharacter()
    if not cCharacter then return end

    if PRP.Property.Tools.Blacklist[sToolName] then Print("blacklisted") return false end

    if CAMI.PlayerHasAccess( pPlayer, "Palomino.Property.BypassToolLimits", nil ) then return true end

    local eEntity = tTrace.Entity
    if eEntity and eEntity:GetClass() ~= "prop_physics" then Print("not prop_physics") return false end

    local oProperty = false
    if eEntity then
        if eEntity:CreatedByMap() then Print("map") return false end
        if not eEntity:GetProperty() then Print("no property 1") return false end

        oProperty = eEntity:GetProperty()

        if oProperty:GetOccupant() ~= pPlayer:GetCharacter() then Print("not ply occ") return false end
    else
        for _, oPropertyCandidate in pairs( cCharacter:GetRentedProperties() ) do
            if oPropertyCandidate:Contains( tTrace.HitPos ) then
                oProperty = oPropertyCandidate
                break
            end
        end

        if not oProperty then Print("no property 2") return false end
    end

    if not oProperty:HasAccess( cCharacter ) then Print("no ply property access") return false end

    if PRP.Property.Tools.Global[sToolName] then return true end

    -- @TODO: Allow the situational tools to be used w/ allowed props.

    return false
end