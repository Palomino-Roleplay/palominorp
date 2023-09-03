PRP = PRP or {}
PRP.Property = PRP.Property or {}

local PLUGIN = PLUGIN

net.Receive( "PRP.Property.Update", function()
    local sPropertyID = net.ReadString()
    local pRenter = net.ReadEntity()

    local oProperty = PRP.Property.Get( sPropertyID )
    if not oProperty then return end

    oProperty:SetRenter( IsValid( pRenter ) and pRenter:GetCharacter() or false )
end )