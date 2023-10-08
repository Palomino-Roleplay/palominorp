local PLUGIN = PLUGIN

PRP.Heist = PRP.Heist or {}
PRP.Heist.List = PRP.Heist.List or {}

function PRP.Heist.Register( oHeist )
    PRP.Heist.List[oHeist:GetID()] = oHeist

    oHeist:Init()
end

function PRP.Heist.Get( sHeist )
    return PRP.Heist.List[sHeist]
end

function PRP.Heist.GetAll()
    return PRP.Heist.List
end