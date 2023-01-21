local PLUGIN = PLUGIN

util.AddNetworkString( "PRP.Devtools.Run" )
util.AddNetworkString( "PRP.Devtools.Print" )
util.AddNetworkString( "PRP.Devtools.Run.Print" )

net.Receive( "PRP.Devtools.Run", function( _, pPlayer )
    local sCode = net.ReadString()

    local fnRunCode = CompileString( sCode, "PRP.Devtools.Run", false )

    local fnOldPrint = print
    local fnOldPrintSpecial = Print
    local fnOldPrintTable = PrintTable

    local function HijackRunPrint( ... )
        -- Gotta do it manually to support printing userdata and entities
        local sText = PRP.Dev.PrettyType( ... )

        net.Start( "PRP.Devtools.Run.Print" )
            net.WriteString( sText )
        net.Send( PRP_PLY )
    end

    print = HijackRunPrint
    Print = HijackRunPrint
    PrintTable = HijackRunPrint
    PRP_PLY = pPlayer
    PRP_POS = pPlayer:GetPos()
    PRP_ENT = pPlayer:GetEyeTrace().Entity
    PRP_CHAR = pPlayer:GetCharacter()
    PRP_BOT = #player.GetBots() ~= 0 and player.GetBots()[ 1 ] or NULL

    if fnRunCode then
        local bStatus, xReturn = pcall( fnRunCode )

        if not bStatus then
            PLUGIN.Print( "Failed to execute:", PRP_PLY )
        end

        PLUGIN.Print( xReturn, PRP_PLY )
    end

    print = fnOldPrint
    Print = fnOldPrintSpecial
    PrintTable = fnOldPrintTable
    PRP_PLY = nil
    PRP_POS = nil
    PRP_ENT = nil
    PRP_CHAR = nil
    PRP_BOT = nil
end )

function PLUGIN.Print( sText, pPlayer )
    if not sText or not isstring( sText ) then return end

    if pPlayer then
        net.Start( "PRP.Devtools.Print" )
            net.WriteString( sText )
        net.Send( pPlayer )

        return
    end

    MsgC(
        Color( 150, 50, 50 ),
        "[PRP Dev] ",
        Color( 156, 241, 255, 200 ),
        sText,
        "\n"
    )
end