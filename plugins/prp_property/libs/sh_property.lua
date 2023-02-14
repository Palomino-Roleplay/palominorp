PRP = PRP or {}
PRP.Property = PRP.Property or {}
PRP.Property.List = PRP.Property.List or {}
PRP.Property.Rentable = PRP.Property.Rentable or {}

function PRP.Property.Register( oProperty )
    PRP.Property.List[oProperty:GetID()] = oProperty

    Print(oProperty:GetID())
    if oProperty:GetRentable() then
        PRP.Property.Rentable[oProperty:GetID()] = oProperty
    end

    if ix.config.Get("DeveloperMode", false) then
        oProperty:Init()
    end
end

function PRP.Property.Get( sProperty )
    return PRP.Property.List[sProperty]
end

function PRP.Property.GetAll()
    return PRP.Property.List
end

function PRP.Property.GetRentable()
    return PRP.Property.Rentable
end