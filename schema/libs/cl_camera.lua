PRP = PRP or {}
PRP.Scene = PRP.Camera or {}
PRP.Scene.Active = false

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
    if #self.properties[sProperty].keyframes == 0 then return self.properties[sProperty].default end
    if #self.properties[sProperty].keyframes == 1 then return self.properties[sProperty].keyframes[1].value end

    local tPrevKeyframe, tNextKeyframe = self:GetKeyframesAt( sProperty, iTimestamp )
    local tProperty = self.properties[sProperty]

    local iLength = ( tNextKeyframe.timestamp - tPrevKeyframe.timestamp )
    local iFraction = ( iTimestamp - tPrevKeyframe.timestamp ) / iLength

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
        drawviewer = false
    }

    return tReturnTable
end

function PRP.Scene.CreateCameraLayer()
    return PRP.Scene.CreateLayer( "Camera" )
end

PRP.Scene.RegisterLayer( "Camera", CAMERA_LAYER, "Base" )

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
function SCENE:Prepare()
    -- Setting some defaults
    self.keyframes = self.keyframes or {}
    self.layers = self.layers or {}

    self.duration = self.duration or 0
    self._globalAnimations = self._globalAnimations or {}

    local oCameraLayer = PRP.Scene.CreateCameraLayer()

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

-- SCENE functions

-- @TODO: Consider soft restart every 6 hours if under a certain playercount
-- See: https://wiki.facepunch.com/gmod/Global.CurTime
-- This is internally defined as a float, and as such it will be affected by precision loss if your server uptime is more than 6 hours, which will cause jittery movement of players and props and inaccuracy of timers, it is highly encouraged to refresh or change the map when that happens (a server restart is not necessary).

function PRP.Scene.Create( tData )
    local oScene = setmetatable( tData or {}, { __index = SCENE } )
    local oCameraLayer = oScene:Prepare()

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
concommand.Add( "prp_testcamera", function()
    local oTestScene, oCameraLayer = PRP.Scene.Create( tData )
    oTestScene:SetDuration( 5 )
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
        },
        ["angles"] = {
            value = Angle( 0, 90, 0 ),
        },
        ["fov"] = {
            value = 60,
        },
    } )

    oTestScene:Start()
end )