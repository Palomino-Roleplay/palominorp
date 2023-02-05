PRP = PRP or {}
PRP.Police = PRP.Police or {}

local tCalls = {}

function PRP.Police.AddPlayerCall( pPlayer )

    PRP.Police.AddCall()
    -- @TODO: Consider putting this in AddCall
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

function PRP.Police.AddCall( tCallData )
    surface.PlaySound( "npc/overwatch/radiovoice/reinforcementteamscode3.wav" )

    -- @TODO: Add the callout
end

net.Receive( "PRP.Police.AddCall", function()
    local vPos = net.ReadVector()
    local sLabel = net.ReadString()
    local sMessage = net.ReadString()

    PRP.Police.AddCall()
    -- @TODO: Consider putting this in AddCall
    PRP.Marker.Create( {
        label = sLabel,
        pos = vPos,
        color = Color( 220, 60, 60),
        duration = ix.config.Get("CalloutFadeTime", 120),
    } )

    chat.AddText( Color( 220, 60, 60 ), "[911]: " .. sMessage )
end )

function PRP.Police.GetCall()
    return tCalls
end

function PRP.Police.RemoveCall( xCalloutID )
    if isplayer( xCalloutID ) then xCalloutID = pPlayer:AccountID() end

    tCalls[xCalloutID] = nil
end