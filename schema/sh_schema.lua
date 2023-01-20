Schema.name = "Palomino Roleplay"
Schema.author = "Palomino Roleplay"
Schema.description = "A player-first roleplay experience."

ix.util.Include("cl_schema.lua")

ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")

-- Hooks

ix.util.Include("hooks/sv_hooks.lua")
ix.util.Include("hooks/sh_hooks.lua")
ix.util.Include("hooks/cl_hooks.lua")

-- Default config values

ix.config.SetDefault( "weaponAlwaysRaised", true )
ix.config.SetDefault( "intro", false )