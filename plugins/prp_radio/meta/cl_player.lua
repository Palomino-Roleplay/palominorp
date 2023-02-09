local PLY = FindMetaTable( "Player" )

function PLY:SetRadioChannel( sChannel )
    net.Start( "PRP.Radio.SetChannel" )
        net.WriteString( sChannel )
    net.SendToServer()
end