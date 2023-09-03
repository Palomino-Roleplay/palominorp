local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    -- @TODO: We should probably do this in a different hook.
    for sPropertyID, oProperty in pairs( PRP.Property.GetAll() ) do
        oProperty:Init()
    end
end

function PLUGIN:CanPlayerAccessDoor( pPlayer, eDoor, iAccess )
    if not IsValid( eDoor ) then return end

    local oProperty = eDoor:GetProperty()
    if not oProperty then return end

    local cCharacter = pPlayer:GetCharacter()
    if not cCharacter then return end

    if oProperty:HasAccess( cCharacter ) then
        return true
    end
end