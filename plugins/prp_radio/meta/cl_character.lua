local CHAR = ix.meta.character

function CHAR:SetRadioChannel( sChannel )
    net.Start( "PRP.Radio.SetChannel" )
        net.WriteString( sChannel )
    net.SendToServer()
end