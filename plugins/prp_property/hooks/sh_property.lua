local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    -- @TODO: We should probably do this in a different hook.
    for sPropertyID, oProperty in pairs( PRP.Property.GetAll() ) do
        oProperty:Init()
    end
end