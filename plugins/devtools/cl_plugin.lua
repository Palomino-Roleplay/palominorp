local PLUGIN = PLUGIN

function PLUGIN.Print( sText )
    MsgC(
        Color( 150, 50, 50 ),
        "[PRP Devtools] ",
        Color( 255, 241, 122, 200 ),
        sText,
        "\n"
    )
end

net.Receive( "PRP.Devtools.Print", function()
    PLUGIN.Print( net.ReadString() )
end )

concommand.Add( "prp_run", function( pPlayer, sCmd, tArgs, sArgs )
    if not LocalPlayer():IsDeveloper() then return end

    net.Start( "PRP.Devtools.Run" )
        net.WriteString( sArgs )
    net.SendToServer()
end )

net.Receive( "PRP.Devtools.Run.Print", function()
    Print( net.ReadString() )
end )