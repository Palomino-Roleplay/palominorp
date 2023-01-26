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
    baseclass.Set(  "PRP.Scene.Layer." .. sType, tTable )

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
        fov = self:GetValue( "fov" ),
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
        Vector( -8058.126953, 10743.914063, 248.207550 ),
        Angle( -6.335949, -140.624832, 0.000000 ),
        controlPoints = {
            Vector( -9122.620117, 12450.714844, 384.818909 ),
            Vector( -7044.165527, 12461.743164, 447.409515 ),
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
        Angle( 2.904051, 173.042465, 0.000000 )
    }
}

local points = { Vector( 100, 100, 0 ), Vector( 200, 200, 0 ), Vector( 300, 100, 0 ), Vector( 400, 200, 0 ) }

hook.Add( "HUDPaint", "BSplinePointExample", function()
	-- Draw the points
	for _, p in ipairs( points ) do
		draw.RoundedBox( 0, p.x - 2, p.y - 2, 4, 4, color_white )
	end

	-- Draw the spline
	local pos = math.BSplinePoint( ( math.cos( CurTime() ) + 1 ) / 2, points, 1 )
	draw.RoundedBox( 0, pos.x - 2, pos.y - 2, 4, 4, Color( 0, 0, 0 ) )
    Print( pos )
end )


hook.Add( "PostDrawTranslucentRenderables", "tsetjhsoeifjosidfj", function()
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
    PRP.Scene.Active:SetDuration( 10 )
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