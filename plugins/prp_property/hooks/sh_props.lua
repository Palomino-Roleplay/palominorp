local PLUGIN = PLUGIN

PRP = PRP or {}
PRP.Prop = PRP.Prop or {}

-- Also see: OnPlayerPhysicsPickup

-- if SERVER then util.AddNetworkString( "PRP.Property.OnPhysgunPickup" ) end

-- if CLIENT then
--     PRP.Prop.PhysgunnedEntity = nil

    -- local function GetPlayersDefensiveProps( oProperty )
    --     -- lmao
    --     local tDefensiveProps = {}

    --     for _, eEntity in pairs( ents.GetAll() ) do
    --         if not IsValid( eEntity ) then continue end
    --         if not eEntity:GetRealty() then continue end
    --         if eEntity:GetRealty() ~= oProperty then continue end

    --         local sCategory = eEntity:GetNW2String( "PRP.Prop.Category", nil )
    --         if not sCategory then continue end

    --         if not string.StartsWith( sCategory, "defensive_props" ) then continue end

    --         table.insert( tDefensiveProps, eEntity )
    --     end

    --     return tDefensiveProps
    -- end

    -- hook.Add( "PostDrawTranslucentRenderables", "PRP.Prop.PostDrawTranslucentRenderables", function()
    --     -- Print( "PhysgunnedEntity:", PRP.Prop.PhysgunnedEntity )
    --     if not IsValid( PRP.Prop.PhysgunnedEntity ) then return end

    --     if not PRP.Prop.PhysgunnedEntity:GetRealty() then return end

    --     local oProperty = PRP.Prop.PhysgunnedEntity:GetRealty()
    --     local bIsDefensiveProp = string.StartsWith( PRP.Prop.PhysgunnedEntity:GetNW2String( "PRP.Prop.Category", "" ), "defensive_props" )
    --     -- local vPos = PRP.Prop.PhysgunnedEntity:GetPos()
    --     local vTargetPos = PRP.Prop.PhysgunnedEntity:GetPos()
    --     local iFloorZ = oProperty:GetFloorZ()

    --     local vHitBoxMin, vHitBoxMax = PRP.Prop.PhysgunnedEntity:GetCollisionBounds()
    --     local vHitBoxMinWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMin )
    --     local vHitBoxMaxWorld = PRP.Prop.PhysgunnedEntity:LocalToWorld( vHitBoxMax )

    --     if bIsDefensiveProp then
    --         vTargetPos.z = iFloorZ
    --         vHitBoxMinWorld.z = iFloorZ
    --     end

    --     local bIntersectingAny = false

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

    --         Print( "lmao we're spending a lot of time on this" )
    --         Print( flDistanceFraction )

    --         local flDisplayFaction = math.min( 1 - flDistanceFraction, 1 )

    --         if flDisplayFaction < 0 then continue end

    --         local bIntersectingZone = util.IsOBBIntersectingOBB(
    --             vTargetPos,
    --             PRP.Prop.PhysgunnedEntity:GetAngles(),
    --             vHitBoxMin,
    --             vHitBoxMax,
    --             vZoneMidpoint,
    --             Angle(0, 0, 0),
    --             -vZoneSize,
    --             vZoneSize,
    --             0
    --         )

    --         local oColor = bIntersectingZone and Color( 255, 0, 0, 255 * flDisplayFaction ) or Color( 200, 0, 0, 255 * flDisplayFaction )

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

    --     Print( "Doing collision check" )
    --     for _, eEntity in pairs( ents.FindInBox( vHitBoxMinWorld, vHitBoxMaxWorld ) ) do
    --         Print( "Entity:", eEntity )

    --         if not IsValid( eEntity ) then continue end
    --         if eEntity:IsWeapon() then continue end
    --         -- if bIntersectingAny then break end

    --         if eEntity == PRP.Prop.PhysgunnedEntity then continue end

    --         -- local bIntersectingEntity = util.IsOBBIntersectingOBB(
    --         --     vTargetPos,
    --         --     PRP.Prop.PhysgunnedEntity:GetAngles(),
    --         --     vHitBoxMin,
    --         --     vHitBoxMax,
    --         --     eEntity:GetPos() + eEntity:OBBCenter(),
    --         --     eEntity:GetAngles(),
    --         --     eEntity:OBBMins(),
    --         --     eEntity:OBBMaxs(),
    --         --     0
    --         -- )

    --         -- Print( "Intersecting Arguments:" )
    --         -- Print( "vTargetPos\t", vTargetPos, "\n" )
    --         -- Print( "PRP.Prop.PhysgunnedEntity:GetAngles()\t", PRP.Prop.PhysgunnedEntity:GetAngles(), "\n" )
    --         -- Print( "vHitBoxMin\t", vHitBoxMin, "\n" )
    --         -- Print( "vHitBoxMax\t", vHitBoxMax, "\n" )
    --         -- Print( "eEntity:GetPos() + eEntity:OBBCenter()\t", eEntity:GetPos() + eEntity:OBBCenter(), "\n" )
    --         -- Print( "eEntity:GetAngles()\t", eEntity:GetAngles(), "\n" )
    --         -- Print( "eEntity:OBBMins()\t", eEntity:OBBMins(), "\n" )
    --         -- Print( "eEntity:OBBMaxs()\t", eEntity:OBBMaxs(), "\n" )

    --         -- if not bIntersectingEntity then continue end

    --         -- Draw the entity's bounds
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

    --     if bIsDefensiveProp then
    --         local oColor = bIntersectingAny and Color( 255, 0, 0 ) or Color( 255, 255, 255 )

    --         render.DrawWireframeBox(
    --             vTargetPos,
    --             PRP.Prop.PhysgunnedEntity:GetAngles(),
    --             vHitBoxMin,
    --             vHitBoxMax,
    --             oColor,
    --             false
    --         )

    --         render.DrawLine(
    --             PRP.Prop.PhysgunnedEntity:GetPos(),
    --             vTargetPos,
    --             oColor,
    --             false
    --         )
    --     end

    --     -- Property Bounds box
    --     -- local tBounds = oProperty:GetBounds()
    --     -- for _, tBound in pairs( tBounds ) do
    --     --     local vMin = tBound[ 1 ]
    --     --     local vMax = tBound[ 2 ]

    --     --     render.DrawWireframeBox(
    --     --         vMin,
    --     --         Angle( 0, 0, 0 ),
    --     --         Vector( 0, 0, 0 ),
    --     --         vMax - vMin,
    --     --         Color( 255, 255, 255 ),
    --     --         true
    --     --     )
    --     -- end
    -- end )

    -- net.Receive( "PRP.Property.OnPhysgunPickup", function( iLen )
    --     local eEntity = net.ReadEntity()
    --     if not IsValid( eEntity ) then return end

    --     -- @TODO: Call our own hook here

    --     PRP.Prop.PhysgunnedEntity = eEntity
    --     Print( "PRP.Prop.PhysgunnedEntity: ", PRP.Prop.PhysgunnedEntity )

    --     local sCategory = eEntity:GetNW2String( "PRP.Prop.Category", nil )
    --     if not sCategory then return end

    --     -- eEntity.m_iOriginalCollisionGroup = eEntity.m_iOriginalCollisionGroup or eEntity:GetCollisionGroup()
    --     -- eEntity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    -- end )
-- end

-- function PLUGIN:OnPhysgunPickup( pPlayer, eEntity )
--     Print( "OnPhysgunPickup" )
--     -- if pPlayer:IsAdmin() then return end
--     if not IsValid( eEntity ) then return end

--     if not eEntity:GetRealty() then return end
--     local oProperty = eEntity:GetRealty()

--     -- When we force drop the entity to the floor, we might go a little bit out of bounds.
--     -- This is to prevent deletion of the entity after the last movement was a force drop.
--     if ( not eEntity._bWasDropped ) and ( not oProperty:Contains( pPlayer:GetPos() ) or not oProperty:Contains( eEntity:GetPos() ) ) then
--         pPlayer:Notify( "You cannot move your props outside of your property." )
--         eEntity:Remove()

--         return false
--     end
--     eEntity._bWasDropped = false

--     if eEntity.OnPhysgunPickup then
--         eEntity:OnPhysgunPickup( pPlayer )
--     end

--     eEntity.m_iOriginalCollisionGroup = eEntity.m_iOriginalCollisionGroup or eEntity:GetCollisionGroup()
--     eEntity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
--     eEntity:SetRenderMode( RENDERMODE_TRANSTEXTURE )
--     eEntity:SetColor4Part( 255, 255, 255, 200 )
--     eEntity:SetRenderFX( 2 )

--     if SERVER then
--         net.Start( "PRP.Property.OnPhysgunPickup" )
--             net.WriteEntity( eEntity )
--         net.Send( pPlayer )
--     end
-- end

