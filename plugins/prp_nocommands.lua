local PLUGIN = PLUGIN

PLUGIN.name = "Command Removal"
PLUGIN.author = "sil"
PLUGIN.description = "Removes some commands"

ix.command.list["becomeclass"] = nil
ix.command.list["pm"] = nil
ix.command.list["reply"] = nil
ix.command.list["setvoicemail"] = nil