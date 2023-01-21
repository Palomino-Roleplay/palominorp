PRP = PRP or {}
PRP.Marker = PRP.Marker or {}

local tMarkers = {}

function PRP.Marker.Create( tMarkerInfo )
    timer.Create( "PRP.Market.Remove." .. #tMarkers, tMarkerInfo.duration or 20, 1, function()
        PRP.Marker.Remove( #tMarkers )
    end )

    return table.insert( tMarkers, table.Merge( {
        label = "<unknown>",
        start = CurTime(),
        duration = 20,
        displayDistance = true,
    }, tMarkerInfo ) )
end

function PRP.Marker.Remove( iMarkerID )
    timer.Remove( "PRP.Market.Remove." .. iMarkerID )
    tMarkers[ iMarkerID ] = nil
end

function PRP.Marker.ClearAll()
    tMarkers = {}
end

-- @TODO: Move this out
COLOR_BLACK = Color( 0, 0, 0 )
COLOR_WHITE = Color( 255, 255, 255 )

hook.Add( "HUDPaint", "PRP.Marker.HUDPaint", function()
    if not LocalPlayer():IsPolice() then return end

    for _, tMarker in ipairs( tMarkers ) do
        local tScreenPos = tMarker.pos:ToScreen()
        if not tScreenPos.visible then continue end

        local flAlpha = 255 * math.ease.InCubic( 1 - ( CurTime() - tMarker.start ) / tMarker.duration )

        draw.DrawText( tMarker.label, "CloseCaption_Bold", tScreenPos.x + 1, tScreenPos.y + 1, ColorAlpha( COLOR_BLACK, flAlpha ), TEXT_ALIGN_CENTER )
        draw.DrawText( tMarker.label, "CloseCaption_Bold", tScreenPos.x, tScreenPos.y, ColorAlpha( tMarker.color, flAlpha ), TEXT_ALIGN_CENTER )

        if tMarker.displayDistance then
            local flDistance = LocalPlayer():GetPos():Distance( tMarker.pos )
            local sDistance = math.Round( flDistance / 16 ) .. "ft"
            draw.DrawText( sDistance, "CloseCaption_Normal", tScreenPos.x + 1, tScreenPos.y + 1 + 20 + 4, ColorAlpha( COLOR_BLACK, flAlpha ), TEXT_ALIGN_CENTER )
            draw.DrawText( sDistance, "CloseCaption_Normal", tScreenPos.x, tScreenPos.y + 20 + 4, ColorAlpha( COLOR_WHITE, flAlpha ), TEXT_ALIGN_CENTER )
        end
    end
end )