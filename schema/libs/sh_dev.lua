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