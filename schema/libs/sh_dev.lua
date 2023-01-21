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