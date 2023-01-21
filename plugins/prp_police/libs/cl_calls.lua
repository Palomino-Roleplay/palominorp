PRP = PRP or {}
PRP.Police = PRP.Police or {}

local tCalls = {}

function PRP.Police.AddCall( pPlayer )
    tCalls[pPlayer:AccountID()] = {
        pos = pPlayer:GetPos(),
        name = pPlayer:GetName(),
        steamid = pPlayer:SteamID(),
        time = CurTime()
    }

    PRP.Marker.Create( {
        label = pPlayer:GetCharacter():GetName(),
        pos = pPlayer:GetPos(),
        color = Color( 220, 60, 60),
        duration = ix.config.Get("CalloutFadeTime", 120),
    } )
end

function PRP.Police.GetCall()
    return tCalls
end

function PRP.Police.RemoveCall( xCalloutID )
    if isplayer( xCalloutID ) then xCalloutID = pPlayer:AccountID() end

    tCalls[xCalloutID] = nil
end