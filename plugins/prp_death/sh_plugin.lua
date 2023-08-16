local PLUGIN = PLUGIN

PLUGIN.name = "Death"
PLUGIN.author = "sil"
PLUGIN.description = "Handles death & respawning."

ix.util.Include("hooks/sv_hooks.lua")

ix.config.Add("spawnTimeFast", 5, "Amount of seconds before a player can trigger a respawn with spacebar.", nil, {
	data = {min = 0, max = 300},
	category = "Palomino"
})

ix.config.Add("spawnTimeFull", 30, "Amount of seconds for the full respawn timer.", nil, {
	data = {min = 0, max = 600},
	category = "Palomino"
})