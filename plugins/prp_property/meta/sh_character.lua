local PLUGIN = PLUGIN

-- We're using character metatable because properties clear when changing characters.
local CHAR = ix.meta.character

function CHAR:GetRentedProperties()
    return self.m_tRentedProperties or {}
end

function CHAR:SetRentedProperties( tProperties )
    self.m_tRentedProperties = tProperties
end

function CHAR:AddRentedProperty( oProperty )
    -- @TODO: There has to be a better way of doing this.
    if table.Count( self:GetRentedProperties() ) <= 0 then
        self.m_tRentedProperties = {}
    end

    if self.m_tRentedProperties[oProperty:GetID()] then return end

    self.m_tRentedProperties[oProperty:GetID()] = oProperty
end

function CHAR:RemoveRentedProperty( oProperty )
    if not self.m_tRentedProperties or not self.m_tRentedProperties[oProperty:GetID()] then return end

    self.m_tRentedProperties[oProperty:GetID()] = nil
end

function CHAR:ClearRentedProperties()
    self.m_tRentedProperties = {}
end

-- @TODO: EWWWW DISGUSTING NAME
-- function CHAR:GetRentedPropertiesByCategory( sCategory )
--     local tProperties = {}

--     -- Not worth caching since we're working with very small tables. (But we can properly do it in AddRentedProperty)
--     for _, oProperty in pairs( self:GetRentedProperties() or {} ) do
--         if oProperty:GetCategory() == sCategory then
--             table.insert( tProperties, oProperty )
--         end
--     end

--     return tProperties
-- end