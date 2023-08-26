local PLUGIN = PLUGIN

function PLUGIN:GetDoorInfo( eDoor )
    local oProperty = eDoor:GetProperty()
    if not oProperty then return end
    if not oProperty:GetRentable() then return {} end

    local sName = oProperty:GetName()
    local sDescription = "Press F2 to rent for "
        .. ix.currency.Get( oProperty:GetRent() )
        .. " every "
        .. ix.config.Get( "propertyRentPaymentInterval", 15 )
        .. " minutes."

    local oColor = ix.config.Get( "color", Color( 255, 255, 255 ) )

    if oProperty:GetRenter() then
        sDescription = "Rented by " .. oProperty:GetRenter():GetName()
    end

    return {
        name = sName,
        description = sDescription,
        color = oColor
    }
end