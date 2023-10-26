PRP = PRP or {}
PRP.API = PRP.API or {}

PRP.API._bInitComplete = PRP.API._bInitComplete or false
PRP.API._bDownloadComplete = false
PRP.API._tMaterials = PRP.API._tMaterials or {}
PRP.API._tMaterialsDownloadQueue = PRP.API._tMaterialsDownloadQueue or {}



-- @TODO: Consider moving this to a hook
if not file.Exists( "palomino", "DATA" ) then
    file.CreateDir( "palomino" )
end


local function DownloadMaterial( sURI, sMaterialParameters )
    local sURL = PRP.API_URL .. "/" .. sURI .. "/" .. ScrW() .. "/" .. ScrH()
    Print( "URL: " .. sURL )
    local sPath = "palomino/" .. sURI .. ".png"
    local sFileName = string.GetFileFromFilename( sPath )

    Print( "Downloading " .. sFileName .. " from " .. sURL .. "..." )

    Print( sURL )

    if file.Exists( sPath, "DATA" ) then
        file.Delete( sPath, "DATA" )
    end

    http.Fetch( sURL, function( sBody, _, _, iResponseCode )
        if iResponseCode == 200 then
            -- Create the directory structure if it doesn't exist
            local sDirectory = string.GetPathFromFilename( sPath )
            if not file.Exists( sDirectory, "DATA" ) then
                file.CreateDir( sDirectory )
            end

            print(sBody)
            file.Write( sPath, sBody )

            PRP.API._tMaterials[sURI] = Material( "data/" .. sPath, sMaterialParameters )

            Print( "Downloaded " .. sFileName .. " to " .. sPath )

            PRP.API._tMaterialsDownloadQueue[sURI] = nil

            if table.Count(PRP.API._tMaterialsDownloadQueue) == 0 then
                PRP.API._bDownloadComplete = true
            end
        else
            error( "Failed to download material from API: " .. sURI .. " (Code: " .. iResponseCode .. ")" )
        end
    end, function( err )
        error( "Failed to download material from API: " .. sURI .. " (" .. err .. ")" )
    end, {
        apikey = PRP.API_KEY,
        steamid = LocalPlayer():SteamID64(),
        steamname = LocalPlayer():SteamName()
    } )
end

function PRP.API.Material( sURI )
    return PRP.API._tMaterials[sURI]
end

function PRP.API.AddMaterial( sURI, sMaterialParameters )
    if PRP.API._tMaterials[sURI] then
        Print( "Material already exists. Skipping material download..." )
        return
    end

    PRP.API._bDownloadComplete = false
    PRP.API._tMaterialsDownloadQueue[sURI] = sMaterialParameters

    if PRP.API._bInitComplete then
        DownloadMaterial( sURI, sMaterialParameters )
    else
        Print( "PAPI not initialized. Skipping material download..." )
    end
end


function PRP.API.Initialize()
    if PRP.API._bInitComplete then
        Print( "PAPI already initialized. Skipping initialization..." )
        return
    end

    --@TODO: What the fuck is wrong with you?
    timer.Simple( 6, function()

        Print( "Initializing PAPI..." )

        Print( "Downloading materials..." )
        for sURI, sMaterialParameters in pairs( PRP.API._tMaterialsDownloadQueue ) do
            Print( sURI )
            DownloadMaterial( sURI, sMaterialParameters )
        end

        Print( "why though?" )

        PRP.API._bInitComplete = true

        Print( "PAPI initialized!" )
    end )
end

-- @TODO: Disgusting
hook.Add( "InitPostEntity", "PRP.API.InitializedPlugins", PRP.API.Initialize )
if PRP.API._bInitComplete then PRP.API.Initialize() end