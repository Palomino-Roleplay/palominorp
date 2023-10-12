local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: Death"
PLUGIN.author = "sil"
PLUGIN.description = "Handles death."

ix.util.Include("hooks/sv_hooks.lua")
ix.util.Include("hooks/cl_hooks.lua")

ix.config.Add("spawnTimeFastEnabled", false, "Whether or not players can fast respawn.", nil, {
	category = "Palomino"
})

ix.config.Add("spawnTimeFast", 5, "Amount of seconds before a player can trigger a respawn with spacebar.", nil, {
	data = {min = 0, max = 300},
	category = "Palomino"
})

ix.config.Add("spawnTimeFull", 30, "Amount of seconds for the full respawn timer.", nil, {
	data = {min = 0, max = 600},
	category = "Palomino"
})