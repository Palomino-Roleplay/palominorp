local PLUGIN = PLUGIN

CreateClientConVar( "prp_dev_hideinfo", "0", true, false, "Show playtesting information on the HUD." )

function PLUGIN:HUDPaint()
    if not PRP.Playtesting.Enabled then return end
    if not LocalPlayer():IsDeveloper() then return true end
    if GetConVar( "prp_dev_hideinfo" ):GetBool() then return end

    surface.SetFont( "DebugOverlay" )

    surface.SetTextColor( 255, 255, 255, 255 )

    surface.SetTextPos( 10, 100 )
    surface.DrawText( "Palomino Playtesting" )

    surface.SetTextColor( 200, 200, 200, 255 )

    surface.SetTextPos( 10, 120 )
    surface.DrawText( "Date: " .. os.date( "%m/%d/%Y" ) )
    surface.SetTextPos( 10, 140 )
    surface.DrawText( "Player: " .. LocalPlayer():SteamName() .. " (" .. LocalPlayer():SteamID() .. ")" )

    surface.SetTextColor( 220, 220, 240, 255 )

    surface.SetTextPos( 10, 170 )
    surface.DrawText( "Scene: " .. "Freeroam" )
    surface.SetTextPos( 10, 190 )
    surface.DrawText( "Role: " .. LocalPlayer():GetLocalVar( "PRP.Playtesting.Role", "UNASSIGNED" ) )
    surface.SetTextPos( 10, 210 )
    surface.DrawText( "Objective: " .. LocalPlayer():GetLocalVar( "PRP.Playtesting.Objective", "N/A" ) )
end