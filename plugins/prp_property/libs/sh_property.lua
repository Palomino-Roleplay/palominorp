PRP = PRP or {}
PRP.Property = PRP.Property or {}
PRP.Property.List = PRP.Property.List or {}

function PRP.Property.Register( oProperty )
    PRP.Property.List[oProperty:GetID()] = oProperty
end

function PRP.Property.Get( sProperty )
    return PRP.Property.List[sProperty]
end

function PRP.Property.GetAll()
    return PRP.Property.List
end