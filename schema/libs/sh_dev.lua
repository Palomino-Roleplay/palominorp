-- @TODO: Consider disabling this in release builds

function Print( ... )
    local tArgs = { ... }

    if not tArgs then return end

    local sText = ""
    for n = 1, #tArgs do
        if istable(tArgs[n]) then
            tArgs[n] = table.ToString( tArgs[n], "Table " .. n .. ":", true )
        end

        sText = sText .. tostring( tArgs[n] )
    end

    MsgC(
        Color( 122, 236, 202),
        sText,
        "\n"
    )
end