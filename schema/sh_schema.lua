Schema.name = "Palomino Roleplay"
Schema.author = "Palomino Roleplay"
Schema.description = "A player-first roleplay experience."

ix.util.Include("cl_schema.lua")

ix.util.Include("meta/sh_character.lua")
ix.util.Include("meta/sh_player.lua")

ix.util.Include("hooks/sh_hooks.lua")

-- Default config values

ix.config.SetDefault( "weaponAlwaysRaised", true )
ix.config.SetDefault( "intro", false )

-- Removing some of the default commands

ix.command.list["becomeclass"] = nil
ix.command.list["pm"] = nil
ix.command.list["reply"] = nil
ix.command.list["setvoicemail"] = nil