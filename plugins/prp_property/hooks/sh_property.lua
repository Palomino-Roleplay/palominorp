local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    for sPropertyID, oProperty in pairs( PRP.Property.GetAll() ) do
        oProperty:Init()
    end
end