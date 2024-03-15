-- Options

ix.option.Set( "observerTeleportBack", false )

PRP.UI = PRP.UI or {}
PRP.UI.ScaleFactor = ScrH() / 1080

concommand.Add( "prp_openhtml", function( pPlayer, sCommand, tArgs, sArgs )
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( ScrW() * 0.75, ScrH() * 0.75 )
    frame:Center()
    frame:SetTitle( "HTML Test" )
    frame:MakePopup()

    local html = vgui.Create( "DHTML", frame )
    html:Dock( FILL )
    html:OpenURL( string.len(sArgs) > 5 and sArgs or "https://semantic-ui.com/" )
end )