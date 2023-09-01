local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: UI"
PLUGIN.author = "sil"
PLUGIN.description = ""

PRP = PRP or {}
PRP.UI = PRP.UI or {}

-- @TODO: Move
if CLIENT then
    PRP.UI.ScaleFactor = ScrH() / 1080

    timer.Create("PRP.UI.Resolution", 10, 0, function()
        local w, h = ScrW(), ScrH()

        if w ~= PRP.UI.ScreenWidth or h ~= PRP.UI.ScreenHeight then
            PRP.UI.ScreenWidth = w
            PRP.UI.ScreenHeight = h

            net.Start("PRP.UI.Resolution")
                net.WriteUInt(w, 16)
                net.WriteUInt(h, 16)
            net.SendToServer()
        end
    end)
end
if SERVER then
    -- @TODO: We want to detect resolution changes on the server because we want to kick unsupported resolutions w/ a custom message.
    -- Perhaps we can do this some other way (e.g. detecting it on loading screen, displaying warning there, then quitting in client)
    -- but that probably sucks too. In any case, I'm so sorry.
    --
    -- We also probably want to discourage people from changing resolutions in-game, so consider doing something else.

    util.AddNetworkString("PRP.UI.Resolution")

    net.Receive("PRP.UI.Resolution", function(len, ply)
        local w = net.ReadUInt(16)
        local h = net.ReadUInt(16)

        if not PRP.UI.AllowedResolutions[w .. "x" .. h] then
            ply:Kick( w .. "x" .. h .. " is an unsupported resolution.\n\nChange to 16:9 or 21:9 resolutions of at least 1280x720" )
        end
    end)
end

ix.util.Include("cl_hooks.lua")