local PLUGIN = PLUGIN

function PLUGIN:HUDPaint()
    if not PRP.Playtesting.Enabled then return end

    surface.SetFont( "DebugOverlay" )

    surface.SetTextColor( 255, 255, 255, 255 )

    surface.SetTextPos( 10, 100 )
    surface.DrawText( "Palomino Playtesting" )

    surface.SetTextColor( 200, 200, 200, 255 )

    surface.SetTextPos( 10, 120 )
    surface.DrawText( "Date: " .. os.date( "%m/%d/%Y" ) )
    surface.SetTextPos( 10, 140 )
    surface.DrawText( "Player: " .. LocalPlayer():SteamName() .. " (" .. LocalPlayer():SteamID() .. ")" )

    surface.SetTextPos( 10, 160 )
    surface.DrawText( "Position: " .. tostring(LocalPlayer():GetPos()))

    surface.SetTextColor( 220, 220, 240, 255 )

    surface.SetTextPos( 10, 190 )
    surface.DrawText( "Scene: " .. "Freeroam" )
    surface.SetTextPos( 10, 210 )
    surface.DrawText( "Role: " .. LocalPlayer():GetLocalVar( "PRP.Playtesting.Role", "UNASSIGNED" ) )
    surface.SetTextPos( 10, 230 )
    surface.DrawText( "Objective: " .. LocalPlayer():GetLocalVar( "PRP.Playtesting.Objective", "N/A" ) )
end