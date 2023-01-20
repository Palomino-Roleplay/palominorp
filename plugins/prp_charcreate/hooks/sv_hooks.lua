local PLUGIN = PLUGIN

function PLUGIN:AdjustCreationPayload( pPlayer, tPayload, tNewPayload )
    -- @TODO: Check whoever sends a different faction than the default one
    tNewPayload.faction = ix.faction.Get( FACTION_CITIZEN ).uniqueID
end