Schema.name = "Palomino Roleplay"
Schema.author = "Palomino Roleplay"
Schema.description = "A player-first roleplay experience."

ix.util.Include("cl_schema.lua")

ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")

-- Default config values

ix.config.SetDefault( "weaponAlwaysRaised", true )