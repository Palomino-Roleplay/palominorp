net.Receive("ixPlayerDeath", function()
	if (IsValid(ix.gui.deathScreen)) then
		ix.gui.deathScreen:Remove()
	end

	ix.gui.deathScreen = vgui.Create("PRP.DeathScreen")
end)

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "PRP.Death.PlayerSpawn", function(data)
    local client = Player(data.userid)

    if (IsValid(client)) then
        if (client == LocalPlayer() and (IsValid(ix.gui.deathScreen))) then
            ix.gui.deathScreen:FadeOut()
        end
    end
end)