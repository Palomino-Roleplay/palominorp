PRP = PRP or {}
PRP.Dev = PRP.Dev or {}

-- @TODO: Consider disabling this in release builds

function PRP.Dev.PrettyType( ... )
    local tArgs = { ... }

    if not tArgs then return end

    local sText = ""
    for n = 1, #tArgs do
        if istable(tArgs[n]) then
            tArgs[n] = table.ToString( tArgs[n], "Table " .. n .. ":", true )
        elseif isfunction(tArgs[n]) then
            local tFunctionInfo = debug.getinfo( tArgs[n] )

            tArgs[n] = "Function " .. n .. ": " .. tFunctionInfo.short_src .. ":" .. tFunctionInfo.linedefined .. "-" .. tFunctionInfo.lastlinedefined .. "\n"
        end

        sText = sText .. tostring( tArgs[n] )
    end

    return sText
end

function Print( ... )
    MsgC(
        Color( 122, 236, 202),
        PRP.Dev.PrettyType( ... ),
        "\n"
    )
end

if CLIENT then
    concommand.Add( "prp_eyepos", function( pPlayer )
        Print( "Vector( " .. math.Round( pPlayer:EyePos().x ) .. ", " .. math.Round( pPlayer:EyePos().y ) .. ", " .. math.Round( pPlayer:EyePos().z ) .. " )" )
    end )

    concommand.Add( "prp_getpos", function( pPlayer )
        Print( "Vector( " .. math.Round( pPlayer:GetPos().x ) .. ", " .. math.Round( pPlayer:GetPos().y ) .. ", " .. math.Round( pPlayer:GetPos().z ) .. " )" )
    end )

    concommand.Add( "prp_getang", function( pPlayer )
        Print( "Angle( " .. math.Round( pPlayer:GetAngles().p ) .. ", " .. math.Round( pPlayer:GetAngles().y ) .. ", " .. math.Round( pPlayer:GetAngles().r ) .. " )" )
    end )

    concommand.Add( "prp_getpos_trace", function()
        local tr = util.TraceLine( {
            start = LocalPlayer():GetShootPos(),
            endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 10000,
            filter = LocalPlayer()
        } )

        Print( "Vector( " .. math.Round( tr.HitPos.x ) .. ", " .. math.Round( tr.HitPos.y ) .. ", " .. math.Round( tr.HitPos.z ) .. " )" )
    end )

    concommand.Add( "prp_getang_trace", function()
        local tr = util.TraceLine( {
            start = LocalPlayer():GetShootPos(),
            endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 10000,
            filter = LocalPlayer()
        } )

        Print( "Angle( " .. math.Round( tr.HitNormal:Angle().p ) .. ", " .. math.Round( tr.HitNormal:Angle().y ) .. ", " .. math.Round( tr.HitNormal:Angle().r ) .. " )" )
    end )
end