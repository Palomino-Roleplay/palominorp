PRP = PRP or {}
PRP.Police = PRP.Police or {}

util.AddNetworkString( "PRP.Police.AddCall" )

function PRP.Police.AddCall( vPos, sLabel, sChatPrint )
    net.Start( "PRP.Police.AddCall" )
        net.WriteVector( vPos )
        net.WriteString( sLabel )
        net.WriteString( sChatPrint )
    net.Send( team.GetPlayers( FACTION_POLICE ) )
    -- @TODO: Add all gov't to the net.Send
end