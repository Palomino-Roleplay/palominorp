local PLUGIN = PLUGIN

local CHAR = ix.meta.character

function CHAR:GetRentedProperties()
    return self.m_tRentedProperties or {}
end

function CHAR:SetRentedProperties( tProperties )
    self.m_tRentedProperties = tProperties
end

function CHAR:AddRentedProperty( oProperty )
    -- @TODO: There has to be a better way of doing this.
    if not self:GetRentedProperties() then
        self:SetRentedProperties( {} )
    end

    table.insert( self:GetRentedProperties(), oProperty )
end

-- @TODO: EWWWW DISGUSTING NAME
function CHAR:GetRentedPropertiesByCategory( sCategory )
    local tProperties = {}

    -- Not worth caching since we're working with very small tables.
    for _, oProperty in pairs( self:GetRentedProperties() or {} ) do
        if oProperty:GetCategory() == sCategory then
            table.insert( tProperties, oProperty )
        end
    end

    return tProperties
end