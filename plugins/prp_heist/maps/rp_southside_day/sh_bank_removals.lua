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

    -- Bank blinking lasers
    [3196] = true,
    [3143] = true,
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

    -- Enable bank lasers on init
    if SERVER then PRP.Heist.Southside.SetBankLasers( true ) end
end

function PLUGIN:AcceptInput( eReceiver, sInput, eActivator, eCaller, xValue )
    -- Disable the blinking laser at the back
    if IsValid( eCaller ) and eCaller:MapCreationID() == 3208 then
        return true
    end

    -- Print("Input:")
    -- Print("Receiver: ", eReceiver, " (", eReceiver:GetName(), ")", " [", eReceiver:MapCreationID(), "]")
    -- Print("Input: ", sInput)
    -- Print("Activator: ", eActivator, " (", eActivator:MapCreationID(), ")")
    -- Print("Caller: ", eCaller, " [", eCaller:MapCreationID(), "] ", " (", eCaller:GetName(), ")")
    -- Print("Value: ", xValue)
    -- Print("\n")

    if sInput ~= "Use" then return end
    if IsValid( eReceiver ) and eReceiver:CreatedByMap() and tHideEnts[eReceiver:MapCreationID()] then
        -- Do some logging here maybe
        if IsValid( eActivator ) and eActivator:IsPlayer() then
            return true
        end
    end
end

-- 3196: Clientside displayed end bank lasers

-- 3218: Trigger for full bank lasers
-- 3143: Trigger for end bank lasers?
-- 3208: End bank lasers logic timer