-- This requires a special module to be installed before it works correctly
-- Sorry to disappoint you
if file.Find("lua/bin/gmcl_gdiscord_*.dll", "GAME")[1] == nil then return end
require("gdiscord")

print("testooo")

local discord_id = "1134931747482652683"
local refresh_time = 15

local discord_start = discord_start or -1

function DiscordUpdate()
    local rpc_data = {}

    print("Discord Update")

    -- @TODO: Update before launch
    rpc_data["state"] = ""
    rpc_data["details"] = ( LocalPlayer():IsDeveloper() and "Developing" or "Playtesting" ) .. " on " .. game.GetMap()
    rpc_data["startTimestamp"] = discord_start
    rpc_data["largeImageKey"] = "sydney"

    if LocalPlayer():GetCharacter() then
        rpc_data["largeImageText"] = LocalPlayer():GetCharacter():GetName()
    end

    -- Determine what type of game is being played
    -- local rpc_data = {}
    -- if game.SinglePlayer() then
    --     rpc_data["state"] = "Singleplayer"
    -- else
    --     local ip = game.GetIPAddress()
    --     if ip == "loopback" then
    --         if GetConVar("p2p_enabled"):GetBool() then
    --             rpc_data["state"] = "Peer 2 Peer"
    --         else
    --             rpc_data["state"] = "Local Server"
    --         end
    --     else
    --         rpc_data["state"] = string.Replace(ip, ":27015", "")
    --     end
    -- end

    -- -- Determine the max number of players
    -- rpc_data["partySize"] = player.GetCount()
    -- rpc_data["partyMax"] = game.MaxPlayers()
    -- if game.SinglePlayer() then rpc_data["partyMax"] = 0 end

    -- -- Handle map stuff
    -- -- See the config
    -- rpc_data["largeImageKey"] = game.GetMap()
    -- rpc_data["largeImageText"] = game.GetMap()
    -- if map_restrict and not map_list[map] then
    --     rpc_data["largeImageKey"] = image_fallback
    -- end
    -- rpc_data["details"] = GAMEMODE.Name
    -- rpc_data["startTimestamp"] = discord_start

    DiscordUpdateRPC(rpc_data)
end

hook.Add("InitializedPlugins", "UpdateDiscordStatus", function()
    discord_start = os.time()

    -- @TODO: This is not okay.
    timer.Simple( 10, function()
        if LocalPlayer():SteamID() == "STEAM_0:0:0" then return end

        DiscordRPCInitialize(discord_id)
        DiscordUpdate()
    
        timer.Create("DiscordRPCTimer", refresh_time, 0, DiscordUpdate)
    end )
end)

-- discord_start = os.time()
-- DiscordRPCInitialize(discord_id)
-- DiscordUpdate()

-- timer.Create("DiscordRPCTimer", refresh_time, 0, DiscordUpdate)