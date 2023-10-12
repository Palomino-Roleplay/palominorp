PaloObject = {}
PaloObject.__index = PaloObject

function PaloObject:new()
    local oNewObject = oNewObject or {}
    setmetatable( oNewObject, PaloObject )

    return oNewObject
end
setmetatable( PaloObject, { __call = PaloObject.new } )


PaloObjectNetworked = PaloObject:new()