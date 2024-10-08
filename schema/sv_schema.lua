-- @TODO: Update
local tHostnames = {
    "Palomino: Under Construction",
}

timer.Create( "Palomino.Hostname", 300, 0, function()
    local sHostname = table.Random( tHostnames )
    game.ConsoleCommand( "hostname \"" .. sHostname .. "\"\n" )

    Print( "Set hostname to '" .. sHostname .. "'" )
end )