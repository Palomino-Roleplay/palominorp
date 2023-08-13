PRP = PRP or {}
PRP.Scene = PRP.Camera or {}

-- EFFECT object

-- LAYER object

local LAYER = {}

AccessorFunc( LAYER, "properties", "Properties" )

AccessorFunc( LAYER, "_type", "Type" )
AccessorFunc( LAYER, "_scene", "Scene" )

function LAYER:Prepare()
    self.properties = self.properties or {}
end

function LAYER:Start()
    self:OnStart()
end

function LAYER:Stop()
    self:OnStop()
end

function LAYER:Finish()
    self:OnFinish()
end

function LAYER:OnStart()
end

function LAYER:OnStop()
end

function LAYER:OnFinish()
end

function LAYER:AddProperty( sName, iType, xDefault, tData )
    self.properties[ sName ] = { type = iType, default = xDefault, data = tData, keyframes = {} }
end

function LAYER:GetProperty( sName )
    return self.properties[ sName ]
end

function LAYER:SetPropertyData( sName, tData )
    self.properties[ sName ].data = tData
end

function LAYER:GetKeyframeByID( sProperty, iKeyframeID )
    return self.keyframes[iKeyframeID] or false
end

function LAYER:GetKeyframeByTimestamp( sProperty, iTimestamp )
    for iKeyframeID, tKeyframe in pairs( self.properties[sProperty].keyframes ) do
        if iTimestamp == tKeyframe.timestamp then
            return tKeyframe, iKeyframeID
        end
    end
end

function LAYER:AddKeyframe( sProperty, iTimestamp, xValue, fnEase )
    if self:HasKeyframes( sProperty ) then
        self:GetKeyframesAt( sProperty, iTimestamp )
    end

    self.properties[sProperty].keyframes = self.properties[sProperty].keyframes or {}
    table.insert( self.properties[ sProperty ].keyframes, {
        timestamp = iTimestamp,
        value = xValue,
        ease = fnEase,
    } )
end

function LAYER:AddKeyframesAt( iTimestamp, tKeyframes )
    for sProperty, tKeyframe in pairs( tKeyframes ) do
        self:AddKeyframe( sProperty, iTimestamp, tKeyframe.value, tKeyframe.ease or false )
    end
end

function LAYER:GetValueAt( sProperty, iTimestamp )
    -- @TODO: Fix running one more time sometimes on last frame

    if #self.properties[sProperty].keyframes == 0 then return self.properties[sProperty].default end
    if #self.properties[sProperty].keyframes == 1 then return self.properties[sProperty].keyframes[1].value end

    local tNextKeyframe, tPrevKeyframe = self:GetKeyframesAt( sProperty, iTimestamp )
    local tProperty = self.properties[sProperty]

    local iLength = ( tNextKeyframe.timestamp - tPrevKeyframe.timestamp )
    local iFraction = ( iTimestamp - tPrevKeyframe.timestamp ) / iLength

    if tNextKeyframe.ease then
        iFraction = tNextKeyframe.ease( iFraction )
    end

    -- @TODO: Move somewhere better.
    if tProperty.type == TYPE_NUMBER then
        return Lerp( iFraction, tPrevKeyframe.value, tNextKeyframe.value )
    elseif tProperty.type == TYPE_VECTOR then
        return LerpVector( iFraction, tPrevKeyframe.value, tNextKeyframe.value )
    elseif tProperty.type == TYPE_ANGLE then
        return LerpAngle( iFraction, tPrevKeyframe.value, tNextKeyframe.value )
    end
end

function LAYER:GetValue( sProperty )
    if self.properties[sProperty].data.GetValue then
        return self.properties[sProperty].data.GetValue( self )
    end

    return self:GetValueAt( sProperty, self:GetScene():GetTimestamp() )
end

-- Get the two keyframes before and after current position
function LAYER:GetKeyframesAt( sProperty, iTimestamp )
    for iKeyframeID, tKeyframe in ipairs( self.properties[sProperty].keyframes ) do
        if tKeyframe.timestamp > iTimestamp then
            return tKeyframe, self.properties[sProperty].keyframes[iKeyframeID - 1], iKeyframeID, iKeyframeID - 1
        end
    end
end

function LAYER:HasKeyframes( sProperty )
    return self.properties[sProperty] and not table.IsEmpty( self.properties[sProperty] )
end

-- Layer factory

PRP.Scene.LayerFactory = {}
-- PRP.Scene.LayerFactory["Base"] = LAYER
function PRP.Scene.RegisterLayer( sType, tTable, sBase )
    tTable.Base = sBase or "Base"
    tTable._type = sType

    PRP.Scene.LayerFactory[sType] = tTable
    baseclass.Set( "PRP.Scene.Layer." .. sType, tTable )

    local tMetatable = {}

    tMetatable.__index = function( t, k )
        if ( PRP.Scene.LayerFactory[ tTable.Base ] and PRP.Scene.LayerFactory[ tTable.Base ][k] ) then return PRP.Scene.LayerFactory[ tTable.Base ][k] end
        return LAYER[k]
    end

    setmetatable( tTable, tMetatable )

    return tTable
end

function PRP.Scene.CreateLayer( sClassname )
    if sClassname == "Base" then return LAYER end

    if PRP.Scene.LayerFactory[sClassname] then
        local tMetatable = PRP.Scene.LayerFactory[sClassname]

        local oLayer = PRP.Scene.CreateLayer( tMetatable.Base )
        oLayer.BaseClass = PRP.Scene.LayerFactory[tMetatable.Base]
        table.Merge( oLayer, tMetatable )

        oLayer:SetType( sClassname )
        oLayer:Prepare()

        if oLayer.Init then oLayer:Init() end

        return oLayer
    end
end

-- Camera Layer Object
local CAMERA_LAYER = {}

function CAMERA_LAYER:Init()
    self:AddProperty( "origin", TYPE_VECTOR, LocalPlayer():EyePos(), {} )
    self:AddProperty( "angles", TYPE_ANGLE, LocalPlayer():EyeAngles(), {} )
    self:AddProperty( "fov", TYPE_NUMBER, LocalPlayer():GetFOV(), {} )
    self:AddProperty( "znear", TYPE_NUMBER, 3, {} )
    self:AddProperty( "zfar", TYPE_NUMBER, 200000, {} )
    self:AddProperty( "drawviewer", TYPE_BOOL, false, {} )
end

function CAMERA_LAYER:OnStart()
    hook.Add( "CalcView", "PRP.Camera.CalcView", function( pPlayer, vOrigin, aAngles, iFOV, iZNear, iZFar )
        return self:CalcView( pPlayer, vOrigin, aAngles, iFOV, iZNear, iZFar )
    end )
end

function CAMERA_LAYER:OnStop()
    hook.Remove( "CalcView", "PRP.Camera.CalcView" )
end

function CAMERA_LAYER:CalcView( pPlayer, vOrigin, aAngles, iFOV, iZNear, iZFar )
    local tReturnTable = {
        origin = self:GetValue( "origin" ),
        angles = self:GetValue( "angles" ),
        fov = self:GetValue( "fov" ),
        znear = self:GetValue( "znear" ),
        zfar = self:GetValue( "zfar" ),
        drawviewer = self:GetValue( "drawviewer" )
    }

    if self.OnCalcView then
        self:OnCalcView( tReturnTable )
    end

    return tReturnTable
end

function PRP.Scene.CreateCameraLayer()
    return PRP.Scene.CreateLayer( "CameraConstant" )
end

PRP.Scene.RegisterLayer( "Camera", CAMERA_LAYER, "Base" )

-- Constant Camera (constant speed)
local CAMERA_CONSTANT = {}

function CAMERA_CONSTANT:Init()
    self.path = {}
    self.distance = 0

    self:AddProperty( "speed", TYPE_NUMBER, 100, {} )
    self:AddProperty( "loop", TYPE_BOOL, false, {} )
    self:AddProperty( "ease", TYPE_FUNCTION, function( a ) return a end, {} )
end

function CAMERA_CONSTANT:AddToPath( vOrigin, aAngles, tControlPoints )
    local iDistanceFromLast = 0

    if tControlPoints then
        -- Recalculate distance, splitting into 100 segments
        local iSegments = 100

        local tPoints = table.Copy( tControlPoints )
        table.insert( tPoints, 1, self.path[#self.path].origin )
        table.insert( tPoints, vOrigin )

        for i=1, iSegments do
            local vPoint = CalculateBezierFromBSplinePoint( i / iSegments, tPoints )
            local vLastPoint = CalculateBezierFromBSplinePoint( (i - 1) / iSegments, tPoints )
            iDistanceFromLast = iDistanceFromLast + vPoint:Distance( vLastPoint )
        end

        local iIndex = table.insert( self.path, {
            origin = vOrigin,
            angles = aAngles,
            distanceStart = self.distance,
            distanceEnd = self.distance + iDistanceFromLast,
            distanceFromLast = iDistanceFromLast,
            controlPoints = tControlPoints,
            points = tPoints
        } )
    else
        iDistanceFromLast = #self.path > 0 and vOrigin:Distance( self.path[#self.path].origin ) or 0

        local iIndex = table.insert( self.path, {
            origin = vOrigin,
            angles = aAngles,
            distanceStart = self.distance,
            distanceEnd = self.distance + iDistanceFromLast,
            distanceFromLast = iDistanceFromLast,
            controlPoints = tControlPoints,
            points = {}
        } )
    end

    self.distance = self.distance + iDistanceFromLast
end

function CAMERA_CONSTANT:GetPathValueAt( sProperty, iTimestamp )
    -- @TODO: Probably wanna use parametric curves and shit. And honestly, could probably make it a property type and use it wherever you want.
    -- @TODO: If no duration, use speed.
    local iTimestampFrac = self:GetScene():GetTimestampFrac( iTimestamp )
    local iCurrentDistance = self.distance * iTimestampFrac
    -- local iCurrentDistance = iTimestampFrac * iDistance

    for iKeyframeID, tKeyframe in ipairs( self.path ) do
        if tKeyframe.distanceEnd > iCurrentDistance then
            local tPrevKeyframe = self.path[iKeyframeID - 1]

            -- @TODO: Weird af
            local iFrac = ( iCurrentDistance - tPrevKeyframe.distanceEnd ) / tKeyframe.distanceFromLast

            if sProperty == "angles" then
                iFrac = math.ease.InOutSine( iFrac )
            end

            -- Print( "iFrac calculation: ( " .. iCurrentDistance .. " - " .. tPrevKeyframe.distanceEnd .. " ) / " .. tKeyframe.distanceFromLast )

            -- Print( "New frame:" )
            -- Print( iFrac )
            -- Print( iFrac )

            if sProperty == "origin" then
                if tKeyframe.controlPoints then
                    return CalculateBezierFromBSplinePoint( iFrac, tKeyframe.points, 1 )
                end

                return LerpVector( iFrac, tPrevKeyframe.origin, tKeyframe.origin )
            elseif sProperty == "angles" then
                return LerpAngle( iFrac, tPrevKeyframe.angles, tKeyframe.angles )
            end
        end
    end
end

function CAMERA_CONSTANT:GetPathValue( sProperty )
    return self:GetPathValueAt( sProperty, self:GetScene():GetTimestamp() )
end

-- function CAMERA_CONSTANT:GetValueAt( sProperty, iTimestamp )
--     if sProperty == "origin" or sProperty == "angles" then
--         return self:GetPathValueAt( sProperty, iTimestamp )
--     end

--     return self.BaseClass.GetValueAt( self, sProperty, iTimestamp )
-- end

function CAMERA_CONSTANT:CalcView( pPlayer, vOrigin, aAngles, iFOV, iZNear, iZFar )
    local tReturnTable = {
        origin = self:GetPathValue( "origin" ),
        angles = self:GetPathValue( "angles" ),
        fov = 60 or self:GetValue( "fov" ),
        znear = self:GetValue( "znear" ),
        zfar = self:GetValue( "zfar" ),
        drawviewer = self:GetValue( "drawviewer" )
    }

    return tReturnTable
end

PRP.Scene.RegisterLayer( "CameraConstant", CAMERA_CONSTANT, "Camera" )

-- SCENE object

local SCENE = {}

-- You *can* edit layers directly, but it'd just be easier to use AddLayer.
AccessorFunc( SCENE, "layers", "Layers" )

-- Edit these for your SCENE config.
AccessorFunc( SCENE, "duration", "Duration" ) -- @TODO Calculate this dynamically

-- Don't edit these unless you know what you're doing
AccessorFunc( SCENE, "_startTime", "StartTime", FORCE_NUMBER )
AccessorFunc( SCENE, "_endTime", "EndTime", FORCE_NUMBER )
AccessorFunc( SCENE, "_camera", "Camera", FORCE_NUMBER )

-- Handling the SCENE shit
function SCENE:Prepare( sCameraClass )
    -- Setting some defaults
    self.keyframes = self.keyframes or {}
    self.layers = self.layers or {}

    self.duration = self.duration or 0
    self._globalAnimations = self._globalAnimations or {}

    local oCameraLayer = PRP.Scene.CreateLayer( sCameraClass )

    self:AddLayer( oCameraLayer )
    self:SetCamera( oCameraLayer )

    return oCameraLayer
end

function SCENE:Start()
    self:SetStartTime( CurTime() )

    -- Set keyframe times so we don't have to do it every frame
    self._keyframeTimestamps = {}
    local iTime = 0
    for i, tKeyframe in ipairs( self.keyframes ) do
        self._keyframeTimestamps[ i ] = iTime
    end

    for _, oLayer in pairs( self.layers ) do
        oLayer:Start()
    end

    timer.Create( "PRP.Scene.Stop", self:GetDuration(), 1, function()
        self:Finish()
    end )

    self:OnStart()
end

function SCENE:OnStart()
    Print("Scene Started")
end

function SCENE:Finish()
    self:Stop()
    self:OnFinish()
end

function SCENE:OnFinish()
    Print("Scene Finished")
end

function SCENE:Stop()
    for _, oLayer in pairs( self.layers ) do
        oLayer:Stop()
    end

    self:OnStop()
end

function SCENE:OnStop()
end

function SCENE:AddLayer( oLayer )
    table.insert( self.layers, LAYER )

    oLayer:SetScene( self )
end

function SCENE:GetTimestamp()
    return CurTime() - self._startTime
end

function SCENE:GetTimestampFrac( iTime )
    return ( iTime or self:GetTimestamp() ) / self:GetDuration()
end

-- SCENE functions

-- @TODO: Consider soft restart every 6 hours if under a certain playercount
-- See: https://wiki.facepunch.com/gmod/Global.CurTime
-- This is internally defined as a float, and as such it will be affected by precision loss if your server uptime is more than 6 hours, which will cause jittery movement of players and props and inaccuracy of timers, it is highly encouraged to refresh or change the map when that happens (a server restart is not necessary).

function PRP.Scene.Create( tData, sCameraClass )
    local oScene = setmetatable( tData or {}, { __index = SCENE } )
    local oCameraLayer = oScene:Prepare( sCameraClass )

    return oScene, oCameraLayer
end

-- function PRP.Scene.Start( tData )
--     PRP.Scenme.Active = setmetatable( tData or {}, { __index = SCENE } )
--     PRP.SCENE.Active:Start()
-- end

-- function PRP.Scene.GetCalcView()
--     if not PRP.SCENE.Active then return end
-- end
-- Test concommands

-- @TODO: Remove this (and any debug) concommands
PRP.Scene.Active = PRP.Scene.Active or nil
concommand.Add( "prp_testcamera_stop", function()
    if PRP.Scene.Active then
        PRP.Scene.Active:Stop()
        PRP.Scene.Active = nil
    end
end )

PRP.Scene.ParamTest = {}

PRP.Scene.ParamTest = {
    {
        Vector( -8909.469727, 14065.680664, 492.507507 ),
        Angle( 26.532043, -83.072632, 0.000000 ),
    },
    {
        Vector( -7933.537598, 11055.622070, 501.927368 ),
        Angle( -6.335949, -140.624832, 0.000000 ),
        controlPoints = {
            Vector( -9122.620117, 12450.714844, 384.818909 ),
            Vector( -7144.165527, 12491.743164, 447.409515 ),
            -- Vector( -6482.790039, 12374.115234, 513.223633 )
        }
    },
    {
        Vector( -13420.223633, 10661.609375, 405.661041 ),
        Angle( 8.184049, -28.821218, 0.000000 ),
        controlPoints = {
            Vector( -9202.992188, 9056.330078, 432.810913 ),
            Vector( -12202.914063, 11384.008789, 474.201874 ),
        }
    },
    {
        Vector( -13683.786133, 8521.658203, -117.900970 ),
        Angle( 2.904051, 173.042465, 0.000000 ),
        controlPoints = {
            Vector( -14639.407227, 9623.210938, 418.308868 ),
            Vector( -12820.377930, 8504.253906, 53.799564 )
        }
    },
    {
        Vector( -14551.575195, 9656.244141, 692.191833 ),
        Angle( 22.868050, -34.476765, 0.000000 ),
        controlPoints = {
            Vector( -14712.918945, 8547.171875, -312.994141 ),
            Vector( -13687.024414, 10280.100586, 631.372742 )
        }
    },
    {
        Vector( -12925.424805, 10890.608398, 1700.462158 ),
        Angle( -41.811935, -65.760735, 0.000000 ),
        controlPoints = {
            Vector( -15313.848633, 9103.367188, 763.346924 ),
            Vector( -14794.770508, 10995.667969, 1684.759399 )
        }
    },
    {
        Vector( -10582.880859, 10330.970703, 981.961670 ),
        Angle( 3.992058, -94.800461, 0.000000 ),
        controlPoints = {
            Vector( -11389.326172, 10801.477539, 1712.655884 ),
            Vector( -11214.162109, 10862.300781, 1007.207397 )
        }
    },
    {
        Vector( -9592.422852, 9511.152344, 334.069458 ),
        Angle( -17.523907, 91.091286, 0.000000 )
    },
    {
        Vector( -9059.455078, 10630.475586, 213.304214 ),
        Angle( 2.144090, -0.252699, 0.000000 ),
        controlPoints = {
            Vector( -8929.914063, 9487.555664, 215.558350 ),
            Vector( -9795.203125, 10679.911133, 639.058853 )
        }
    },
    {
        Vector( -4956.271973, 10430.616211, 400.524170 ),
        Angle( 15.608089, -135.456268, 0.000000 ),
        controlPoints = {
            Vector( -8951.448242, 10667.985352, -330.970459 ),
            Vector( -4739.313965, 11127.822266, 500.424072 )
        }
    },
    {
        Vector( -5583.189453, 8433.306641, 101.042458 ),
        Angle( 3.464097, -91.764191, 0.000000 ),
        controlPoints = {
            Vector( -5136.088379, 9910.834961, 361.150238 ),
            Vector( -5895.925293, 9097.495117, 109.876915 )
        }
    },
    {
        Vector( -4935.776855, 3337.165771, -108.900574 ),
        Angle( -0.099901, -169.907761, 0.000000 ),
        controlPoints = {
            Vector( -5351.652344, 7931.601074, 95.111252 ),
            Vector( -4352.577637, 5849.111328, -2.957237 )
        }
    }
}

local points = { Vector( 100, 100, 0 ), Vector( 200, 200, 0 ), Vector( 300, 100, 0 ), Vector( 400, 200, 0 ) }

hook.Add( "HUDPaint", "BSplinePointExample", function()
	-- -- Draw the points
	-- for _, p in ipairs( points ) do
	-- 	draw.RoundedBox( 0, p.x - 2, p.y - 2, 4, 4, color_white )
	-- end

	-- -- Draw the spline
	-- local pos = math.BSplinePoint( ( math.cos( CurTime() ) + 1 ) / 2, points, 1 )
	-- draw.RoundedBox( 0, pos.x - 2, pos.y - 2, 4, 4, Color( 0, 0, 0 ) )
end )


hook.Add( "PostDrawTranslucentRenderables", "tsetjhsoeifjosidfj", function()
    if true then return end
    if PRP.Scene.Active then return end

    for iIndex, tData in ipairs( PRP.Scene.ParamTest ) do
        render.DrawWireframeSphere( tData[ 1 ], 10, 10, 10, Color( 255, 0, 0 ), false )
        if iIndex ~= 1 then
            if tData.controlPoints then
                for _, vPos in ipairs( tData.controlPoints ) do
                    render.DrawWireframeSphere( vPos, 10, 10, 10, Color( 0, 255, 0 ), false )
                end

                local iDetail = 10
                local tPoints = table.Copy( tData.controlPoints )
                table.insert( tPoints, 1, PRP.Scene.ParamTest[ iIndex - 1 ][ 1 ] )
                table.insert( tPoints, tData[ 1 ] )

                -- Print( tPoints )

                local vLastSpline = tPoints[ 1 ]
                for i=1, iDetail do
                    -- Print( tPoints )
                    local vSpline = CalculateBezierFromBSplinePoint( i / iDetail, tPoints, 1 )
                    render.DrawLine( vLastSpline, vSpline, Color( 255, 100, 0 ), false )
                    vLastSpline = vSpline
                end
            else
                render.DrawLine( tData[ 1 ], PRP.Scene.ParamTest[ iIndex - 1 ][ 1 ], Color( 255, 0, 0 ), false )
            end
        end
    end
end )

function CalculateBezierCurve( p0, p1, p2, p3, t )
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t

    local x = uuu * p0.x + 3 * uu * t * p1.x + 3 * u * tt * p2.x + ttt * p3.x
    local y = uuu * p0.y + 3 * uu * t * p1.y + 3 * u * tt * p2.y + ttt * p3.y
    local z = uuu * p0.z + 3 * uu * t * p1.z + 3 * u * tt * p2.z + ttt * p3.z

    return Vector( x, y, z )
end

function CalculateBezierFromBSplinePoint( t, tPoints, anything )
    return CalculateBezierCurve( tPoints[1], tPoints[2], tPoints[3], tPoints[4], t )
end


concommand.Add( "prp_testcamera_constant", function()
    if PRP.Scene.Active then
        PRP.Scene.Active:Stop()
        PRP.Scene.Active = nil
    end

    local oCameraLayer
    PRP.Scene.Active, oCameraLayer = PRP.Scene.Create( {}, "CameraConstant" )
    PRP.Scene.Active:SetDuration( 30 )
    -- oCameraLayer:AddToPath( Vector( -8909.469727, 14065.680664, 492.507507 ), Angle( 26.532043, -83.072632, 0.000000 ) )
    -- oCameraLayer:AddToPath( Vector( -8058.126953, 10743.914063, 248.207550 ), Angle( -6.335949, -140.624832, 0.000000 ) )
    -- oCameraLayer:AddToPath( Vector( -13420.223633, 10661.609375, 405.661041 ), Angle( 8.184049, -28.821218, 0.000000 ) )
    -- oCameraLayer:AddToPath( Vector( -13683.786133, 8521.658203, -117.900970 ), Angle( 2.904051, 173.042465, 0.000000 ) )

    for iIndex, tData in ipairs( PRP.Scene.ParamTest ) do
        oCameraLayer:AddToPath( tData[ 1 ], tData[ 2 ], tData.controlPoints )
    end

    PRP.Scene.Active:Start()
end )

concommand.Add( "prp_testcamera", function()
    if PRP.Scene.Active then
        PRP.Scene.Active:Stop()
        PRP.Scene.Active = nil
    end

    local oCameraLayer
    PRP.Scene.Active, oCameraLayer = PRP.Scene.Create( {}, "Camera" )
    PRP.Scene.Active:SetDuration( 10 )
    oCameraLayer:AddKeyframesAt( 0, {
        ["origin"] = {
            value = Vector( -13641.609375, 8560.702148, -129.284241 ),
        },
        ["angles"] = {
            value = Angle( 0, 0, 0 ),
        },
        ["fov"] = {
            value = 90,
        },
    } )

    oCameraLayer:AddKeyframesAt( 5, {
        ["origin"] = {
            value = Vector( -9566.824219, 8605.231445, -76.645660 ),
            ease = math.ease.InOutCirc,
        },
        ["angles"] = {
            value = Angle( 0, 90, 0 ),
            ease = math.ease.InOutCirc,
        },
        ["fov"] = {
            value = 30,
            ease = math.ease.InOutCirc,
        },
    } )

    oCameraLayer:AddKeyframesAt( 10, {
        ["origin"] = {
            value = Vector( -9494.595703, 10672.708008, 445.866150 ),
        },
        ["angles"] = {
            value = Angle( 5.544, -43.595, 0.000 ),
        },
        ["fov"] = {
            value = 99,
        },
    } )

    PRP.Scene.Active:Start()
end )

concommand.Add( "prp_printkeyframe", function()
    print( "oCameraLayer:AddKeyframesAt( XXXX, {" )
    print( "\t[\"origin\"] = {" )
    print( "\t\tvalue = Vector( " .. tostring( LocalPlayer():GetPos() ) .. " )," )
    print( "\t}," )
    print( "\t[\"angles\"] = {" )
    print( "\t\tvalue = Angle( " .. tostring( LocalPlayer():GetAngles() ) .. " )," )
    print( "\t}," )
    print( "\t[\"fov\"] = {" )
    print( "\t\tvalue = " .. tostring( LocalPlayer():GetFOV() ) .. "," )
    print( "\t}," )
    print( "} )" )
end )

-- soundIntro = soundIntro or nil
-- concommand.Add( "prp_intro_start", function()
--     soundIntro = CreateSound( game.GetWorld(), "prp/music/intro.wav" )
--     soundIntro:SetSoundLevel( 0 )
--     print("tset")
--     soundIntro:Play()

--     timer.Simple( 11.85, function()
--         if IsValid( ix.gui.characterMenu ) then
--             ix.gui.characterMenu:Show()
--         else
--             print("INVALID characterMenu PANEL: RECREATING")
--             vgui.Create( "ixCharMenu" )
--         end
--     end )

--     if PRP.Scene.Active then
--         PRP.Scene.Active:Stop()
--         PRP.Scene.Active = nil
--     end

--     local oCameraLayer
--     PRP.Scene.Active, oCameraLayer = PRP.Scene.Create( {}, "Camera" )
--     PRP.Scene.Active:SetDuration( 120 )
--     oCameraLayer:AddKeyframesAt( 0, {
--         ["origin"] = {
--             value = Vector( 4844.553711, 3787.858154, 319.442963 ),
--         },
--         ["angles"] = {
--             value = Angle( 9.745, 115.881, 0.000 ),
--         },
--         ["fov"] = {
--             value = 57.528999328613,
--         },
--     } )

--     oCameraLayer:AddKeyframesAt( 1.749, {
--         ["origin"] = {
--             value = Vector( 4844.553711, 3787.858154, 319.442963 ),
--         },
--         ["angles"] = {
--             value = Angle( 9.745, 115.881, 0.000 ),
--         },
--         ["fov"] = {
--             value = 57.528999328613,
--         },
--     } )

--     -- Town Hall Scene
--     oCameraLayer:AddKeyframesAt( 1.749, {
--         ["origin"] = {
--             value = Vector( 4844.553711, 3787.858154, 319.442963 ),
--         },
--         ["angles"] = {
--             value = Angle( 9.745, 115.881, 0.000 ),
--         },
--         ["fov"] = {
--             value = 57.528999328613,
--         },
--     } )

--     oCameraLayer:AddKeyframesAt( 6.789, {
--         ["origin"] = {
--             value = Vector( 3576.289063, 4064.288818, 882.850403 ),
--         },
--         ["angles"] = {
--             value = Angle( 33.951, 59.496, 0.000 ),
--         },
--         ["fov"] = {
--             value = 57.528999328613,
--         },
--     } )

--     -- 2nd Scene
--     oCameraLayer:AddKeyframesAt( 6.789, {
--         ["origin"] = {
--             value = Vector( 5828.634766, 425.616821, 733.374634 ),
--         },
--         ["angles"] = {
--             value = Angle( 20.512, -69.932, 0.000 ),
--         },
--         ["fov"] = {
--             value = 46.539970397949,
--         },
--     } )

--     oCameraLayer:AddKeyframesAt( 11.85, {
--         ["origin"] = {
--             value = Vector( 5881.332520, 547.302368, 254.859848 + 64 ),
--         },
--         ["angles"] = {
--             value = Angle( -7.824, -79.301, 0.000 ),
--         },
--         ["fov"] = {
--             value = 46.539970397949,
--         },
--     } )

--     -- Main menu scene
--     oCameraLayer:AddKeyframesAt( 11.85, {
--         ["origin"] = {
--             value = Vector( 1264.394653, -164.328842, 350.462677+32 ),
--         },
--         ["angles"] = {
--             value = Angle( -6.983, -64.039, 0.000 ),
--         },
--         ["fov"] = {
--             value = 47.232997894287,
--         },
--     } )

--     oCameraLayer:AddKeyframesAt( 11.85 + 3, {
--         ["origin"] = {
--             value = Vector( 1124.571655, 122.807968, 311.343658+32 ),
--             ease = math.ease.OutCubic
--         },
--         ["angles"] = {
--             value = Angle( -6.983, -64.039, 0.000 ),
--             ease = math.ease.OutCubic
--         },
--         ["fov"] = {
--             value = 33.273956298828,
--             ease = math.ease.OutCubic
--         },
--     } )

--     oCameraLayer:AddKeyframesAt( 120, {
--         ["origin"] = {
--             value = Vector( 1124.571655, 122.807968, 311.343658+32 ),
--         },
--         ["angles"] = {
--             value = Angle( -6.983, -64.039, 0.000 ),
--         },
--         ["fov"] = {
--             value = 33.273956298828,
--         },
--     } )

--     oCameraLayer.OnCalcView = function( oLayer, oView )
--         -- if oLayer:GetScene():GetTimestamp() < 11.85 then return end

--         local iNoiseP = PRP.Math.GetPerlinNoise(1, CurTime()) * 2 - 1
--         local iNoiseSlowP = PRP.Math.GetPerlinNoise(1, CurTime() * 0.25 + 100) * 2 - 1

--         local iNoiseY = PRP.Math.GetPerlinNoise(1, CurTime() + 7) * 2 - 1
--         local iNoiseSlowY = PRP.Math.GetPerlinNoise(1, CurTime() * 0.25 + 25) * 2 - 1

--         local iNoiseR = PRP.Math.GetPerlinNoise(1, CurTime() + 14) * 2 - 1
--         local iNoiseSlowR = PRP.Math.GetPerlinNoise(1, CurTime() * 0.25 + 57) * 2 - 1

--         oView.angles = oView.angles + Angle(
--             ( iNoiseSlowP * 0.5 ) + ( iNoiseP * 0.1 ),
--             ( iNoiseSlowY * 0.5 ) + ( iNoiseY * 0.1 ),
--             ( iNoiseSlowR * 1 ) + ( iNoiseR * 0.1 )
--         )
--     end

--     PRP.Scene.Active:Start()
-- end )

-- concommand.Add( "prp_intro_stop", function()
--     RunConsoleCommand( "prp_testcamera_stop" )
--     soundIntro:FadeOut( 5 )
-- end )

-- hook.Add( "CharacterLoaded", "PRP.Camera.CharacterLoaded", function()
--     RunConsoleCommand( "prp_intro_stop" )
-- end )

local matBG = Material( "prp/InventoryBG.png" )

-- @TODO: Redo, but holy shit this is cool
hook.Add( "PostDrawOpaqueRenderables", "AAAAAHOLYSHIT", function()
    -- if PRP.Scene.Active then
        cam.Start3D2D( Vector( 1666, -1124, 621 ), Angle( 0, 180, 90 ), 0.8 )
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawRect( 0, 0, 450, 240 )

            draw.NoTexture()
            surface.SetDrawColor( 255, 255, 255, 128 )
            surface.SetMaterial( matBG )
            surface.DrawTexturedRect( 0, 0, 450, 240 )

            surface.SetTextColor( 255, 255, 255 )
            surface.SetFont( "ixMenuButtonHugeFont" )

            local sTitle = "Palomino"
            local iW, iH = surface.GetTextSize( sTitle )

            surface.SetTextPos( 225 - iW / 2, 120 - iH / 2 )
            surface.DrawText( "Palomino" )

            -- surface.SetFont( "ixMenuButtonLabelFont" )
            -- surface.SetTextPos( 50, 60 )
            -- surface.DrawText( "welcome to..." )
        cam.End3D2D()
    -- end
end )