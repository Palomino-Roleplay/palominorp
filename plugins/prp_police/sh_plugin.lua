local PLUGIN = PLUGIN

PLUGIN.name = "Police"
PLUGIN.author = "sil"
PLUGIN.description = "Adds basic police functionality."

ix.util.Include( "meta/sv_player.lua" )
ix.util.Include( "meta/sv_character.lua" )
ix.util.Include( "meta/sh_character.lua" )

ix.util.Include( "hooks/sv_hooks.lua" )
ix.util.Include( "hooks/sh_hooks.lua" )
ix.util.Include( "hooks/cl_hooks.lua" )

PLUGIN.PrisonPositions = {
    Vector( 2940, 2203, 144 + 16 ),
}

-- 911

ix.chat.Register("911", {
    format = "%s has called 911: \"%s\"",
    GetColor = function(self, speaker, text)
        return Color( 220, 60, 60)
    end,
    CanHear = function( self, pSpeaker, pListener )
        if pSpeaker == pListener then return true end
        if pListener:IsPolice() then return true end

        return pSpeaker:GetPos():Distance(pListener:GetPos()) <= ix.config.Get( "chatRange", 280 )
    end,
    CanSay = function(self, pSpeaker, sText)
        if pSpeaker._last911 and pSpeaker._last911 + ix.config.Get("911Cooldown", 300) > CurTime() then
            pSpeaker:Notify( "You must wait " .. math.ceil(pSpeaker._last911 + ix.config.Get("911Cooldown", 300) - CurTime()) .. " seconds before calling 911 again." )
            return false
        end

        -- @TODO: Think this through and probably add a catch-all function
        if pSpeaker:IsRestricted() or pSpeaker:GetCharacter():IsArrested() or not pSpeaker:Alive() then
            pSpeaker:Notify( "You cannot call 911 right now." )
            return false
        end

        pSpeaker._last911 = CurTime()

        return true
    end,
    prefix = {"/911"},
    description = "Call the authorities.",
    indicator = "Talking on the phone...",
})

ix.config.Add("911Cooldown", 300, "How many seconds before players are able to call 911 again", nil, {
    data = {min = 1, max = 900, decimals = 0},
    category = "Police"
})

ix.config.Add("CalloutFadeTime", 120, "How many seconds before a callout fades off of an officer's screen", nil, {
    data = {min = 1, max = 600, decimals = 0},
    category = "Police"
})

-- Arresting

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

-- Ticketing

ix.char.RegisterVar("tickets", {
    default = {},
    isLocal = true,
    bNoDisplay = true,
    field = "tickets",
    fieldType = ix.type.text
})

ix.config.Add("MaxTicketPrice", 120, "What's the maximum price for a ticket?", nil, {
    data = {min = 0, max = 10000, decimals = 0},
    category = "Police"
})

ix.config.Add("TicketOverdueTime", 24 * 3, "After how many hours are tickets declared overdue?", nil, {
    data = {min = 1, max = 24 * 7, decimals = 0},
    category = "Police"
})