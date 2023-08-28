local PLUGIN = PLUGIN

-- See PROPERTY:AddProp in meta/sh_property.lua
function PLUGIN:EntityNetworkedVarChanged( eEntity, sKey, sOldValue, sNewValue )
    Print( "EntityNetworkedVarChanged" )
    Print( eEntity )
    Print( sKey )
    Print( sOldValue )
    Print( sNewValue )

    if sKey ~= "PRP.Property" then return end
    if not sNewValue then return end

    local oProperty = PRP.Property.Get( sNewValue )

    Print( "Adding prop..." )
    oProperty:AddProp( eEntity )
end