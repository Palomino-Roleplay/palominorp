PRP = PRP or {}
PRP.API = PRP.API or {}

-- @TODO: AIDS
PRP.UI = PRP.UI or {}
PRP.UI.AllowedResolutions = PRP.UI.AllowedResolutions or {}

-- @TODO Hell no
function PRP.API.Initialize()
    http.Fetch( PRP.API_URL .. "/ui/resolutions", function( sBody, _, _, iResponseCode )
        if iResponseCode == 200 then
            Print( "Successfully connected to API server" )

            local tResolutions = util.JSONToTable( sBody )
            if not tResolutions then
                Print( "Failed to parse resolutions" )
                Print( "Shutting down server..." )
                while true do end
            end

            for _, tResolution in pairs( tResolutions ) do
                PRP.UI.AllowedResolutions[ tResolution.width .. "x" .. tResolution.height ] = true
            end

            Print( "Loaded " .. table.Count( PRP.UI.AllowedResolutions ) .. " resolutions" )
        else
            Print( "Failed to connect to API server: " .. iResponseCode )
            Print( "Shutting down server..." )
            while true do end
        end
    end, function( err )
        Print( "Failed to fetch resolutions: " .. err )
        Print( "Shutting down server..." )
        while true do end
    end )
end
-- hook.Add( "InitPostEntity", "PRP.API.InitializedPlugins", PRP.API.Initialize )
timer.Simple( 0, function() PRP.API.Initialize() end )