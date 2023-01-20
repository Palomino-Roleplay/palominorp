local PLUGIN = PLUGIN

PLUGIN.name = "Police"
PLUGIN.author = "sil"
PLUGIN.description = "Adds basic police functionality."

ix.util.Include( "sh_arrest.lua" )

ix.util.Include( "meta/sv_character.lua" )
ix.util.Include( "meta/sh_character.lua" )

ix.util.Include( "hooks/sv_hooks.lua" )
ix.util.Include( "hooks/sh_hooks.lua" )
ix.util.Include( "hooks/cl_hooks.lua" )

PLUGIN.PrisonPositions = {
    Vector( 2940, 2203, 144 + 16 ),
}

ix.command.Add("Arrest", {
    description = "Arrests a character and puts them in jail.",
    adminOnly = true,
    arguments = {
        ix.type.character,
        ix.type.number,
        ix.type.text
    },
    OnRun = function( self, pAdmin, target, minutes, reason )
        local bSucceeded, sError = target:Arrest( nil, minutes * 60, reason )
        return sError or "Sent " .. target:GetName() .. " to jail for " .. minutes .. " minute(s)."
    end
} )

ix.command.Add("Unarrest", {
    description = "Unarrests a character.",
    adminOnly = true,
    arguments = {
        ix.type.character
    },
    OnRun = function( self, pAdmin, target )
        local bSucceeded, sError = target:Unarrest()
        return sError or "Unarrested " .. target:GetName() .. "."
    end
} )