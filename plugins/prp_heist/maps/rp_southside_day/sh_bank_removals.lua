local PLUGIN = PLUGIN

local tRemoveEnts = {
    -- Vault Wheel Things
    [3127] = true,
    [3128] = true,

    -- Inner Vault Door Button
    [3198] = true,

    -- Outer Vault Door Button
    [3123] = true,

    -- Inner Vault Shelves
    [3149] = true,
    [3150] = true,

    -- Random shit (weird key lock things at the bank vault pre-room)
    [5075] = true,
    [5076] = true,
}

local tHideEnts = {
    -- Security Office Buttons
    [5097] = true, -- Alarm
    [5095] = true, -- Vault (inner)
    [3142] = true, -- Security Barriers
    [3194] = true, -- Laser System
    [5096] = true, -- Outer Doors

    -- Security Office Button Sprites
    [3420] = true,
    [3421] = true,
    [3422] = true,
    [3423] = true,
}

function PLUGIN:InitPostEntity()
    for _, eEntity in pairs(ents.GetAll()) do
        if not IsValid( eEntity ) then continue end
        if tRemoveEnts[eEntity:MapCreationID()] then eEntity:Remove() end
        if tHideEnts[eEntity:MapCreationID()] then
            eEntity.AcceptInput = function( this, sInput, eActivator )
                if IsValid( eActivator ) and eActivator:IsPlayer() then return false end
            end

            eEntity:SetNoDraw( true )
            eEntity:SetNotSolid( true )
        end

    end

    local eBankFloor = ents.GetMapCreatedEntity( 4171 )
    if eBankFloor then
        eBankFloor:SetPos( Vector( -1788, 3180, -304 ) )
    end
end

function PLUGIN:AcceptInput( eReceiver, sInput, eActivator, eCaller, xValue )
    if sInput ~= "Use" then return end
    if IsValid( eReceiver ) and eReceiver:CreatedByMap() and tHideEnts[eReceiver:MapCreationID()] then
        -- Do some logging here maybe
        if IsValid( eActivator ) and eActivator:IsPlayer() then
            return true
        end
    end
end