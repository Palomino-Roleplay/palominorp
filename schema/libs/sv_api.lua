PRP = PRP or {}

require( "gwsockets" )

util.AddNetworkString( "PRP.API.Challenge" )

PRP.API = PRP.API or {}
PRP.API.bInitialized = PRP.API.bInitialized or true

PRP.API.SessionToken = nil
PRP.API.ServerInfo = PRP.API.ServerInfo or {}

PRP.API.Config = {
    heartbeatInterval = 10
}

-- @TODO: AIDS
PRP.UI = PRP.UI or {}
PRP.UI.AllowedResolutions = PRP.UI.AllowedResolutions or {}

PRP.UI.AllowedResolutions = {
    ["1280x720"] = true,
    ["1600x900"] = true,
    ["1920x1080"] = true,
    ["2560x1440"] = true,
    ["3840x2160"] = true,
    ["2560x1080"] = true,
    ["3440x1440"] = true,
    ["5120x2160"] = true
}

-- @TODO: Change to local variable
PRP._WebSocket = PRP._WebSocket or nil

PRP.API.WS = PRP.API.WS or {}
-- PRP.API.WS._tCallbacks = PRP.API.WS._tCallbacks or {}
PRP.API.WS._tCallbacks = {}

function PRP.API.WS.Log( sMessage )
    MsgC(
        Color( 255, 255, 255, 255 ),
        "[",
        Color( 137, 191, 255, 255 ),
        "PAPI-WS",
        Color( 255, 255, 255, 255 ),
        "] ",
        Color( 255, 255, 255, 255 ),
        sMessage,
        "\n"
    )
end

PRP.API.REST = {}

function PRP.API.REST.HTTP( tHTTPRequest, fnOK, fnFailed )
    -- @TODO: Queue requests if not initialized or disconnected
    tHTTPRequest.url = PRP.API_REST_URL .. tHTTPRequest.url
    -- tHTTPRequest.url = tHTTPRequest.url

    tHTTPRequest.timeout = tHTTPRequest.timeout or 10

    tHTTPRequest.headers = tHTTPRequest.headers or {}
    tHTTPRequest.headers["x-session-token"] = PRP.API.SessionToken
    tHTTPRequest.headers["Content-Type"] = "application/json"
    Print( "Session token: ", PRP.API.SessionToken )

    tHTTPRequest.success = tHTTPRequest.success or function( iResponseCode, sBody, tHeaders )
        if iResponseCode == 200 then
            PRP.API.REST.Log( "Request successful: " .. tHTTPRequest.url )

            if fnOK then
                fnOK( iResponseCode, sBody, tHeaders )
            end
            return
        end

        -- @TODO: Maybe re-authenticate when we implement OAuth2
        PRP.API.REST.Log( "Request failed: " .. tHTTPRequest.url .. " (" .. iResponseCode .. ") \"" .. sBody .. "\"" )
        if fnFailed then fnFailed( iResponseCode .. ": " .. sBody ) end
    end

    tHTTPRequest.failed = tHTTPRequest.failed or function( sError )
        PRP.API.REST.Log( "Request failed: " .. tHTTPRequest.url .. " (" .. iResponseCode or 0 .. ")" )
        if fnFailed then fnFailed( sError ) end
    end

    PRP.HTTP( tHTTPRequest )
end

function PRP.API.REST.Log( sMessage )
    MsgC(
        Color( 255, 255, 255, 255 ),
        "[",
        Color( 163, 137, 255),
        "PAPI-REST",
        Color( 255, 255, 255, 255 ),
        "] ",
        Color( 255, 255, 255, 255 ),
        sMessage,
        "\n"
    )
end

if pcall(require, "chttp") and CHTTP ~= nil then
    PRP.HTTP = CHTTP
    PRP.API.REST.Log( "Using CHTTP" )
else
    PRP.HTTP = HTTP
    PRP.API.REST.Log( "Using HTTP" )
end

function PRP.API.WS.OnMessage( sType, fnCallback )
    if not PRP.API.WS._tCallbacks[ sType ] then
        PRP.API.WS._tCallbacks[ sType ] = {}
    end

    table.insert( PRP.API.WS._tCallbacks[ sType ], fnCallback )
end

function PRP.API.WS.Send( sType, tData )
    if not PRP._WebSocket then return end

    local tMessage = {
        type = sType,
        data = tData
    }

    PRP._WebSocket:write( util.TableToJSON( tMessage ) )
end

-- Makes sure REST API is working too
local function fnInitializeREST()
    PRP.API.REST.Log( "Attempting to connect to REST API server..." )

    PRP.API.REST.HTTP(
        {
            url = "/server",
            method = "GET",
        },
        -- Success
        function( iResponseCode, sBody, tHeaders )
            local tBody = util.JSONToTable( sBody )

            if not tBody then
                PRP.API.REST.Log( "Failed to parse body" )
                PRP.API.REST.Log( "Shutting down server..." )
                -- while true do end
            end

            if not tBody.realm or tBody.realm ~= "server" then
                PRP.API.REST.Log( "Invalid realm" )
                PRP.API.REST.Log( "Shutting down server..." )
                -- while true do end
            end

            if not tBody.version then
                PRP.API.REST.Log( "Invalid version" )
                PRP.API.REST.Log( "Shutting down server..." )
                -- while true do end
            end

            PRP.API.REST.Log( "Successfully connected to PAPI (v" .. tBody.version .. ")" )

            PRP.API.bInitialized = true
            hook.Run( "PRP.API.Initialized", tBody.version )
        end,

        -- Failed
        function( sError )
            PRP.API.REST.Log( "Failed to connect to REST API server: " .. sError )
            PRP.API.REST.Log( "Shutting down server..." )
            -- while true do end
        end
    )
end

-- @TODO Hell no
function PRP.API.Initialize()
    if PRP._WebSocket and PRP._WebSocket:isConnected() then
        PRP.API.WS.Log( "Aborting API Initialization: Already connected to WebSocket server." )
        return
        -- PRP._WebSocket:close()
    end

    local sPalominoEnvironment = file.Read( "gamemodes/" .. Schema.folder .. "/palomino.json", true )
    if not sPalominoEnvironment then
        ErrorNoHalt( "CRITICAL: Failed to read palomino.json", "\n" )
        Print( "Shutting down server..." )

        -- while true do end
    end

    local tPalominoEnvironment = util.JSONToTable( sPalominoEnvironment )
    if not tPalominoEnvironment then
        ErrorNoHalt( "CRITICAL: Failed to parse palomino.json", "\n" )
        Print( "Shutting down server..." )

        -- while true do end
    end

    PRP.API_REST_URL = tPalominoEnvironment.api.rest_url
    PRP.API_WS_URL = tPalominoEnvironment.api.websocket_url

    if not PRP.API_REST_URL then
        ErrorNoHalt( "CRITICAL ERROR: Missing API REST URL", "\n" )
        Print( "Shutting down server..." )

        -- while true do end
    end

    if not PRP.API_WS_URL then
        ErrorNoHalt( "CRITICAL ERROR: Missing API WS URL", "\n" )
        Print( "Shutting down server..." )

        -- while true do end
    end

    PRP._WebSocket = GWSockets.createWebSocket( PRP.API_WS_URL )
    PRP._WebSocket:setHeader( "x-api-key", tPalominoEnvironment.api.key )

    function PRP._WebSocket:onMessage( sMessage )
        Print("Received message")
        PRP.API.WS.Log( sMessage )

        -- Convert message from JSON to table
        local tMessage = util.JSONToTable( sMessage )

        -- Check if the message is valid
        if not tMessage then
            ErrorNoHalt( "Invalid PAPI-WS message received: " .. sMessage, "\n" )
            return
        end

        if tMessage.type == "auth" then
            PRP.API.SessionToken = tMessage.sessionToken
            PRP.API.ServerInfo = tMessage.serverInfo

            PRP.API.WS.Log( "Successfully authenticated server as \"" .. PRP.API.ServerInfo.name .. "\"" )
            Print( "Session token: ", PRP.API.SessionToken )

            -- timer.Simple( 0, fnInitializeREST )
            fnInitializeREST()
            return
        end

        if not PRP.API.bInitialized then
            PRP.API.WS.Log( "Server not initialized. Ignoring message of type \"" .. tMessage.type .. "\"" )
            return
        end

        -- Run all callbacks for this message type
        if PRP.API.WS._tCallbacks[ tMessage.type ] then
            for _, fnCallback in pairs( PRP.API.WS._tCallbacks[ tMessage.type ] ) do
                fnCallback( tMessage.data )
            end
        end
    end

    function PRP._WebSocket:onError( sErrorMessage )
        ErrorNoHalt("Error: ", sErrorMessage, "\n" )
    end

    function PRP._WebSocket:onConnected()
        PRP.API.WS.Log( "Connected to WebSocket server." )

        timer.Create("PRP.API.WS.Heartbeat", 10, 0, function()
            if not PRP.API.bInitialized then return end
            PRP._WebSocket:write( util.TableToJSON( { type = "heartbeat" } ) )
        end)
    end

    function PRP._WebSocket:onDisconnected()
        PRP.API.WS.Log( "Disconnected from WebSocket server." )

        timer.Remove("PRP.API.WS.Heartbeat")

        fnInitializeREST()
        -- PRP.API.bInitialized = false

        -- @TODO: Attempt reconnect w/ session token
    end

    PRP.API.WS.Log( "Attempting to connect to WebSocket server..." )
    PRP._WebSocket:open()
end
hook.Add( "InitPostEntity", "PRP.API.InitPostEntity", PRP.API.Initialize )
-- timer.Simple( 0, function() PRP.API.Initialize() end )

-- @TODO: Remove
-- PRP.API.Initialize()

hook.Add( "PlayerLoadedCharacter", "PRP.API.PlayerLoadedCharacter", function( pPlayer, cCharacter )
    if not PRP.API.bInitialized then return end

    PRP.API.WS.Send( "authCreateChallenge", {
        steamID = pPlayer:SteamID64(),
        character = cCharacter:GetID()
    } )
end )

PRP.API.WS.OnMessage( "auth/challengeCreated", function( tData )
    Print( "Received player challenge code from authentication server." )

    Print( tData )

    local sSteamID = tData.steamId
    local pPlayer = player.GetBySteamID64( sSteamID )
    local iCharacterID = tData.characterId

    if not IsValid( pPlayer ) then return end
    if not pPlayer:GetCharacter() then return end
    if pPlayer:GetCharacter():GetID() ~= iCharacterID then return end

    local sChallenge = tData.challenge

    net.Start( "PRP.API.Challenge" )
        net.WriteString( sChallenge )
    net.Send( pPlayer )
end )

concommand.Add( "prp_reauth", function( pPlayer, sCommand, tArgs, sArgs )
    Print( "Reauthenticating player: " .. pPlayer:Name() )

    if not pPlayer:IsDeveloper() then return end

    PRP.API.WS.Send( "auth/createChallenge", {
        steamId = pPlayer:SteamID64(),
        characterId = pPlayer:GetCharacter():GetID()
    } )
end )

concommand.Add( "prp_api_init", function()
    PRP.API.Initialize()
end )

concommand.Add( "prp_api_close", function()
    if PRP._WebSocket then
        PRP._WebSocket:close()
    end
end )

--
-- Events
--

