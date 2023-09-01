local PLUGIN = PLUGIN

local tRemoveEnts = {
    -- Security Office Buttons
    [5097] = true,
    [5095] = true,
    [3142] = true,
    [3194] = true,
    [5096] = true,

    -- Security Office Button Sprites
    [3420] = true,
    [3421] = true,
    [3422] = true,
    [3423] = true,

    -- Vault Wheel Things
    [3127] = true,
    [3128] = true,

    -- Inner Vault Door Button
    [3198] = true,

    -- Outer Vault Door Button
    [3123] = true,
}

function PLUGIN:InitPostEntity()
    for _, eEntity in pairs(ents.GetAll()) do
        if not IsValid( eEntity ) then continue end
        if tRemoveEnts[eEntity:MapCreationID()] then eEntity:Remove() end

        -- Fix vault floor position
        if eEntity:MapCreationID() == 4171 then
            eEntity:SetPos( Vector( -1788, 3180, -304 ) )
        end
    end
end