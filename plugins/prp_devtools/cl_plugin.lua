local PLUGIN = PLUGIN

PRP = PRP or {}
PRP.Dev = PRP.Dev or {}
PRP.Dev.BugReportPanel = PRP.Dev.BugReportPanel or nil

function PLUGIN.Print( sText )
    MsgC(
        Color( 150, 50, 50 ),
        "[PRP Devtools] ",
        Color( 255, 241, 122, 200 ),
        sText,
        "\n"
    )
end

net.Receive( "PRP.Devtools.Print", function()
    PLUGIN.Print( net.ReadString() )
end )

concommand.Add( "prp_run", function( pPlayer, sCmd, tArgs, sArgs )
    if not LocalPlayer():IsDeveloper() then return end

    net.Start( "PRP.Devtools.Run" )
        net.WriteString( sArgs )
    net.SendToServer()
end )

net.Receive( "PRP.Devtools.Run.Print", function()
    Print( net.ReadString() )
end )

function PLUGIN:InitializedPlugins()
    list.Set(
        "DesktopWindows",
        "prp.dev.bugreport",
        {
            title = "Report a Bug",
            icon = "vgui/spawnmenu/broken",
            init = function(icon, window)
                PRP.Dev.OpenBugReportPanel()
            end
        }
    )

    local tList = list.GetForEdit( "DesktopWindows" )

    tList[ "VCMod" ] = nil
    tList[ "PACEditor" ] = nil
    tList[ "PlayerEditor" ] = nil
    -- tList[ "PACAssetBrowser" ] = nil
end

local function BugReportSuccess( iCode, sBody )
    surface.PlaySound("garrysmod/save_load1.wav")

    notification.AddLegacy( "Bug report submitted successfully.", NOTIFY_GENERIC, 5 )
end

local function BugReportFailure( sDescription, sSteps )
    surface.PlaySound("resource/warning.wav")
    Derma_Message("The bug reporter encountered a bug and could not submit the report. Please submit it in the Discord. Your text is printed in the console.", "Bug Reporter Failed", "OK")

    Print("===PALOMINO BUG REPORT==")
    Print("Description:")
    Print( sDescription )
    Print("Steps to Reproduce:")
    Print( sSteps )
end

local function TakeScreenshot( iQuality, fnCallback )
    local bScreenshotTaken = false

    hook.Add( "PostRender", "PRP.Devtools.TakeScreenshot", function()
        if bScreenshotTaken then return end
        bScreenshotTaken = true

        surface.PlaySound( "npc/scanner/scanner_photo1.wav" )
        local sImageData = render.Capture({
            format = "jpeg",
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH(),
            quality = iQuality,
        })

        -- We need to write it in order to retrieve render.Capture result for some reason
        file.Write( "palomino/bugreport.jpeg", sImageData )

        file.Delete( "palomino/bugreport.jpeg" )

        hook.Remove( "PostRender", "PRP.Devtools.TakeScreenshot" )

        fnCallback( sImageData )
    end )
end

local function TakeConsoleScreenshot( fnCallback )
    RunConsoleCommand( "showconsole" )
    surface.PlaySound( "npc/scanner/scanner_scan2.wav" )

    timer.Simple( 1, function()
        TakeScreenshot( 100, function( sConsoleScreenshotData )
            gui.HideGameUI()

            fnCallback( sConsoleScreenshotData )
        end )
    end )
end

local function SendBugReport( sScreenshotData, bSendTrace, sDescription, sSteps, sConsoleScreenshotData )
    surface.PlaySound("garrysmod/content_downloaded.wav")

    local tWebhookData = {
        embeds = {
            {
                title = "Steps to Reproduce:",
                description = "```" .. sSteps .. "```",
                color = 16711680,
                fields = {
                    {name = "User", value = LocalPlayer():SteamName(), inline = true},
                    {name = "Character", value = LocalPlayer():GetCharacter():GetName() .. " (# " .. LocalPlayer():GetCharacter():GetID() .. ")", inline = true},
                    {name = "SteamID", value = LocalPlayer():SteamID(), inline = true},
                    {name = "Faction", value = ix.faction.indices[ LocalPlayer():GetCharacter():GetFaction() ].name .. " (" .. LocalPlayer():GetCharacter():GetFaction() .. ")", inline = true},
                    {name = "Resolution", value = ScrW() .. "x" .. ScrH(), inline = true},
                    {name = "Position", value = tostring(LocalPlayer():GetPos()), inline = true},
                },
            }
        }
    }

    if bSendTrace then
        local eTrace = LocalPlayer():GetEyeTraceNoCursor().Entity
        if IsValid( eTrace ) then
            local tEntTraceData = {
                ent = eTrace:GetClass(),
                mdl = eTrace:GetModel(),
                mapID = eTrace:MapCreationID(),
                nw = eTrace:GetNWVarTable(),
                nw2 = eTrace:GetNW2VarTable(),
            }

            table.insert( tWebhookData.embeds[1].fields, {name = "EntTrace", value = "```" .. util.TableToJSON( tEntTraceData, true ) .. "```", inline = false } )
        else
            table.insert( tWebhookData.embeds[1].fields, {name = "EntTrace", value = "```" .. "Trace ran without a hit." .. "```", inline = false } )
        end
    end

    local tHTTPRequest = {}
    tHTTPRequest.method = "POST"
    tHTTPRequest.url = "https://discord.com/api/webhooks/1144631966021455933/yDKeOn7DXaDc6LBAYJWM0He0iEB7MMq5WXa3hAmsK68uHTQUmujFaaHAdjn2m38xFBys"
    tHTTPRequest.success = function( iCode, sResponseBody, tHeaders )
        if iCode == 200 or iCode == 204 then
            BugReportSuccess( iCode, sResponseBody )
        else
            Print( "HTTP RESPONSE:" )
            Print( iCode )
            Print( sResponseBody )

            BugReportFailure( sDescription, sSteps )
        end
    end
    tHTTPRequest.failed = function()
        BugReportFailure( sDescription, sSteps )
    end

    tWebhookData.content = "# " .. sDescription

    if sScreenshotData or sConsoleScreenshotData then
        -- @TODO: Ughhhhhhh
        if sScreenshotData then
            tWebhookData.embeds[1].image = {
                url = "attachment://screenshot.jpeg"
            }
        end

        if sConsoleScreenshotData then
            tWebhookData.embeds[1].thumbnail = {
                url = "attachment://console.jpeg"
            }
        end

        local sBoundary = "----WebKitFormBoundardy" .. util.CRC("boundary" .. SysTime())
        local sPayloadBody = "--" .. sBoundary .. "\r\n"
        sPayloadBody = sPayloadBody .. 'Content-Disposition: form-data; name="payload_json"\r\n'
        sPayloadBody = sPayloadBody .. 'Content-Type: application/json\r\n\r\n'
        sPayloadBody = sPayloadBody .. util.TableToJSON(tWebhookData)
        sPayloadBody = sPayloadBody .. "\r\n--" .. sBoundary

        local iFile = 0

        if sScreenshotData then
            sPayloadBody = sPayloadBody .. "\r\n"

            sPayloadBody = sPayloadBody .. 'Content-Disposition: form-data; name="files['..iFile..']"; filename="screenshot.jpeg"\r\n'
            sPayloadBody = sPayloadBody .. 'Content-Type: image/jpeg\r\n\r\n'
            sPayloadBody = sPayloadBody .. sScreenshotData
            sPayloadBody = sPayloadBody .. "\r\n--" .. sBoundary

            iFile = iFile + 1
        end

        if sConsoleScreenshotData then
            sPayloadBody = sPayloadBody .. "\r\n"

            sPayloadBody = sPayloadBody .. 'Content-Disposition: form-data; name="files['..iFile..']"; filename="console.jpeg"\r\n'
            sPayloadBody = sPayloadBody .. 'Content-Type: image/jpeg\r\n\r\n'
            sPayloadBody = sPayloadBody .. sConsoleScreenshotData
            sPayloadBody = sPayloadBody .. "\r\n--" .. sBoundary

            iFile = iFile + 1
        end

        sPayloadBody = sPayloadBody .. "--"

        tHTTPRequest.body = sPayloadBody
        tHTTPRequest.headers = {
            ["Content-Type"] = "multipart/form-data; boundary=" .. sBoundary
        }
    else
        tHTTPRequest.body = util.TableToJSON(tWebhookData)
        -- tHTTPRequest.parameters = tWebhookData
        tHTTPRequest.headers = {
            ["Content-Type"] = "application/json"
        }
    end

    HTTP(tHTTPRequest)
end

function PRP.Dev.BugReport( bSendScreenshot, bSendTrace, sDescription, sSteps, bSendConsoleScreenshot )
    if IsValid( PRP.Dev.BugReportPanel ) then
        PRP.Dev.BugReportPanel:Hide()
    end

    -- @TODO: Oof
    if bSendScreenshot then
        TakeScreenshot( 80, function( sScreenshotData )
            if bSendConsoleScreenshot then
                TakeConsoleScreenshot( function( sConsoleScreenshotData )
                    SendBugReport( sScreenshotData, bSendTrace, sDescription, sSteps, sConsoleScreenshotData )
                end )
            else
                SendBugReport( sScreenshotData, bSendTrace, sDescription, sSteps )
            end
        end )
    elseif bSendConsoleScreenshot then
        TakeConsoleScreenshot( function( sConsoleScreenshotData )
            SendBugReport( nil, bSendTrace, sDescription, sSteps, sConsoleScreenshotData )
        end )
    else
        SendBugReport( nil, bSendTrace, sDescription, sSteps )
    end
end

function PRP.Dev.OpenBugReportPanel()
    if IsValid( PRP.Dev.BugReportPanel ) then
        PRP.Dev.BugReportPanel:Close()
    end

    PRP.Dev.BugReportPanel = vgui.Create( "DFrame" )
    PRP.Dev.BugReportPanel:SetTitle( "Palomino Bug Reporting Tool" )
    PRP.Dev.BugReportPanel:SetSize( 500, 300 )
    PRP.Dev.BugReportPanel:SetPos( ScrW() / 2 - ( PRP.Dev.BugReportPanel:GetWide() / 2 ), ScrH() - ( PRP.Dev.BugReportPanel:GetTall() ) - 50 )
    PRP.Dev.BugReportPanel:MakePopup()

    local dIconLayout = vgui.Create( "DIconLayout", PRP.Dev.BugReportPanel )
    dIconLayout:Dock( FILL )
    dIconLayout:SetSpaceY( 5 )

    -- Bug Description
    local dBugDescription = dIconLayout:Add( "DLabel" )
    dBugDescription:SetText( "What is the bug?" )
    dBugDescription:Dock( TOP )

    local dDescription = dIconLayout:Add( "DTextEntry" )
    dDescription:Dock( TOP )
    dDescription:SetMultiline( false )
    dDescription:SetPlaceholderText( "Be descriptive" )

    -- Steps to Reproduce
    local dStepsToReproduce = dIconLayout:Add( "DLabel" )
    dStepsToReproduce:SetText( "How to reproduce the bug?" )
    dStepsToReproduce:Dock( TOP )

    local dSteps = dIconLayout:Add( "DTextEntry" )
    dSteps:SetMultiline( true )
    dSteps:SetPlaceholderText( "What were you doing? Step-by-step descriptions are the most useful." )
    dSteps:SetTall( 100 )
    dSteps:Dock( TOP )

    -- Include Screenshot Checkbox
    local dIncludeScreenshot = dIconLayout:Add( "DCheckBoxLabel" )
    dIncludeScreenshot:SetText( "Send a screenshot of your screen" )
    dIncludeScreenshot:SetChecked( true )
    dIncludeScreenshot:Dock( TOP )

    -- Include Screenshot Checkbox
    local dIncludeConsoleScreenshot = dIconLayout:Add( "DCheckBoxLabel" )
    dIncludeConsoleScreenshot:SetText( "Send a screenshot of your console (wait ~3 seconds)" )
    dIncludeConsoleScreenshot:SetChecked( false )
    dIncludeConsoleScreenshot:Dock( TOP )

    -- Include Screenshot Checkbox
    local dIncludeTrace = dIconLayout:Add( "DCheckBoxLabel" )
    dIncludeTrace:SetText( "Send the entity you're directly looking at" )
    dIncludeTrace:SetChecked( false )
    dIncludeTrace:Dock( TOP )

    -- Submit Button
    -- local dSubmitConsole = dIconLayout:Add( "DButton" )
    -- dSubmitConsole:SetText( "Submit Bug Report with Console Screenshot" )
    -- dSubmitConsole:Dock( BOTTOM )

    -- dSubmitConsole.DoClick = function()
    --     PRP.Dev.BugReport(  true, dIncludeTrace:GetChecked(), dDescription:GetValue(), dSteps:GetValue(), dIncludeConsoleScreenshot:GetValue() )
    -- end

    -- Submit Button
    local dSubmit = dIconLayout:Add( "DButton" )
    dSubmit:SetText( "Submit Bug Report" )
    dSubmit:Dock( BOTTOM )

    dSubmit.DoClick = function()
        PRP.Dev.BugReport(  dIncludeScreenshot:GetChecked(), dIncludeTrace:GetChecked(), dDescription:GetValue(), dSteps:GetValue(), dIncludeConsoleScreenshot:GetChecked() )
    end
end

concommand.Add( "prp_bugreport_panel", PRP.Dev.OpenBugReportPanel )
concommand.Add( "prp_bugreport", function( pPlayer, sCmd, tArgs )
    local bSendScreenshot = tArgs[1] ~= "1"
    local bSendConsoleScreenshot = tArgs[2] == "1"
    local bSendTrace = tArgs[3] == "1"

    Print( bSendScreenshot )
    Print( bSendConsoleScreenshot )
    Print( bSendTrace )

    PRP.Dev.BugReport( bSendScreenshot, bSendTrace, "Quick Bug Report", "Sent via prp_bugreport", bSendConsoleScreenshot )
end )