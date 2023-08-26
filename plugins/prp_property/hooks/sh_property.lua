local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    for sPropertyID, oProperty in pairs( PRP.Property.GetAll() ) do
        oProperty:Init()
    end
end

-- @TODO: We probably want to make our own way of checking door access & rip out helix's entirely
function PLUGIN:CanPlayerAccessDoor( pPlayer, eEntity, iAccessType )
    if eEntity:GetProperty() then
        return eEntity:GetProperty():HasAccess( pPlayer )
    end
end