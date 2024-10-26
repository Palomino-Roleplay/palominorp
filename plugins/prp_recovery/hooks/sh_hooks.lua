local PLUGIN = PLUGIN

-- function PLUGIN:SetupMove( pPlayer, oMove, oCommand )
--     if pPlayer:InVehicle() then return end

--     local iRecoveryEndTime = pPlayer:GetLocalVar( "recoveryTimeEnd", false )
--     local iRecoveryDuration = pPlayer:GetLocalVar( "recoveryTimeDuration", 30 )

--     if not iRecoveryEndTime then return end
--     if iRecoveryEndTime <= CurTime() then return end

--     local iRecoveryFraction = math.ease.InQuad( math.max( 1 + ( ( CurTime() - iRecoveryEndTime ) / iRecoveryDuration ), 0.5 ) )

--     oMove:SetMaxClientSpeed( oMove:GetMaxClientSpeed() * iRecoveryFraction )
-- end