local PLUGIN = PLUGIN

-- function PLUGIN:HUDPaint()
--     if not LocalPlayer():Alive() then return end
--     if not LocalPlayer():GetCharacter() then return end

--     local iRecoveryTime = LocalPlayer():GetLocalVar( "recoveryTimeEnd", false )
--     if not iRecoveryTime then return end

--     local iTime = math.max( iRecoveryTime - CurTime(), 0 )

--     if iTime > 0 then
--         -- @TODO: This looks like hot garbage. Make it look better.
--         local iWidth, iHeight = ScrW(), ScrH()
--         local iX, iY = iWidth / 2, 20
--         local iAlpha = 255

--         local iScale = iTime / 5
--         iAlpha = iAlpha * iScale

--         local iText = "You are recovering from your injuries."

--         surface.SetFont( "ixMenuButtonFont" )
--         local iTextWidth, iTextHeight = surface.GetTextSize( iText )
--         surface.SetTextColor( 255, 255, 255, iAlpha )
--         surface.SetTextPos( iX - iTextWidth / 2, iY )
--         surface.DrawText( iText )

--         iY = iY + iTextHeight + 5

--         surface.SetFont( "ixMenuButtonHugeFont" )
--         local sTime = string.FormattedTime( iTime, "%02i:%02i" )
--         local iTimerWidth, iTimerHeight = surface.GetTextSize( sTime )
--         surface.SetTextColor( 255, 255, 255, iAlpha )
--         surface.SetTextPos( iX - iTimerWidth / 2, iY )
--         surface.DrawText( sTime )

--         iY = iY + iTimerHeight + 5

--         if not LocalPlayer():IsInHospital() then
--             local sHospitalText = "You need remain inside the hospital to recover fully!"
--             surface.SetFont( "ixMenuButtonFont" )
--             local iHospitalTextWidth, iHospitalTextHeight = surface.GetTextSize( sHospitalText )
--             surface.SetTextColor( 255, 255, 255, iAlpha )
--             surface.SetTextPos( iX - iHospitalTextWidth / 2, iY )
--             surface.DrawText( sHospitalText )
--         end
--     end
-- end