-- @TODO: Update
local tHostnames = {
    "A beautiful place is under construction: Palomino",
    "Off in the distance, a new world is being built: Palomino",
    "Somehow, this is still a work in progress: Palomino",
    "A new world is being built: Palomino",
    "All visa applications are being denied: Palomino",
}

timer.Create( "Palomino.Hostname", 300, 0, function()
    local sHostname = table.Random( tHostnames )
    game.ConsoleCommand( "hostname \"" .. sHostname .. "\"\n" )

    Print( "Set hostname to '" .. sHostname .. "'" )
end )