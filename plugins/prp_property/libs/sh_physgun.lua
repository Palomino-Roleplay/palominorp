PRP = PRP or {}
PRP.Property = PRP.Property or {}

-- function PRP.Property.IsIntersecting( eEntity )
--     if not eEntity:GetProperty() then return end

--     local oProperty = eEntity:GetProperty()
--     local bIsDefensiveProp = string.StartsWith( eEntity:GetNW2String( "PRP.Prop.Category", "" ), "defensive_props" )
--     -- local vPos = eEntity:GetPos()
--     local vTargetPos = eEntity:GetPos()
--     local iFloorZ = oProperty:GetFloorZ()

--     local vHitBoxMin, vHitBoxMax = eEntity:GetCollisionBounds()
--     local vHitBoxMinWorld = eEntity:LocalToWorld( vHitBoxMin )
--     local vHitBoxMaxWorld = eEntity:LocalToWorld( vHitBoxMax )

--     if bIsDefensiveProp then
--         vTargetPos.z = iFloorZ
--         vHitBoxMinWorld.z = iFloorZ
--     end

--     local bIntersectingAny = false
--     local tIntersections = {}

--     -- prop_blacklist zone
--     local tBlacklistZones = oProperty:GetZonesOfType( "prop_blacklist" )
--     for _, oZone in pairs( tBlacklistZones ) do
--         local vZoneMidpoint = ( oZone.pos[ 1 ] + oZone.pos[ 2 ] ) / 2

--         local vZoneSize = Vector(
--             math.abs(oZone.pos[1].x - oZone.pos[2].x) / 2,
--             math.abs(oZone.pos[1].y - oZone.pos[2].y) / 2,
--             math.abs(oZone.pos[1].z - oZone.pos[2].z) / 2
--         )

--         local flZoneMaxAxis = math.max( vZoneSize.x, vZoneSize.y )
--         local flZoneMinAxis = math.min( vZoneSize.x, vZoneSize.y )

--         local flDistance = vTargetPos:DistToSqr( vZoneMidpoint )
--         local flShapeRatio = flZoneMaxAxis / flZoneMinAxis
--         local flDistanceFraction = ( ( flDistance / ( flZoneMaxAxis * flZoneMaxAxis ) ) / flShapeRatio ) / 2

--         -- local flFadePercentage = math.Clamp( flDistanceFraction / flShapeRatio, 0, 1 )

--         local flDisplayFaction = math.min( 1 - flDistanceFraction, 1 )

--         if flDisplayFaction < 0 then continue end

--         local bIntersectingZone = util.IsOBBIntersectingOBB(
--             vTargetPos,
--             eEntity:GetAngles(),
--             vHitBoxMin,
--             vHitBoxMax,
--             vZoneMidpoint,
--             Angle(0, 0, 0),
--             -vZoneSize,
--             vZoneSize,
--             0
--         )
--         render.DrawWireframeBox(
--             oZone.pos[ 1 ],
--             Angle( 0, 0, 0 ),
--             Vector( 0, 0, 0 ),
--             oZone.pos[ 2 ] - oZone.pos[ 1 ],
--             Color( 0, 0, 0, 255 * flDisplayFaction )
--         )

--         render.SetColorMaterial()

--         render.DrawBox(
--             oZone.pos[ 1 ],
--             Angle( 0, 0, 0 ),
--             Vector( 0, 0, 0 ),
--             oZone.pos[ 2 ] - oZone.pos[ 1 ],
--             Color( 255, 0, 0, 32 * flDisplayFaction ),
--             true
--         )

--         bIntersectingAny = bIntersectingAny or bIntersectingZone
--     end

--     for _, eEntity in pairs( ents.FindInBox( vHitBoxMinWorld, vHitBoxMaxWorld ) ) do
--         if not IsValid( eEntity ) then continue end
--         if eEntity:IsWeapon() then continue end
--         -- if bIntersectingAny then break end

--         if eEntity == eEntity then continue end

--         render.DrawWireframeBox(
--             eEntity:GetPos(),
--             eEntity:GetAngles(),
--             eEntity:OBBMins(),
--             eEntity:OBBMaxs(),
--             Color( 255, 0, 0 ),
--             false
--         )

--         bIntersectingAny = true
--     end
-- end