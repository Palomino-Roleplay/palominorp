local PLUGIN = PLUGIN

PLUGIN.name = "Skills"
PLUGIN.author = "sil"
PLUGIN.description = ""

ix.command.list["charsetattribute"].alias = {"CharSetSkill"}
ix.command.list["charaddattribute"].alias = {"CharAddSkill"}

ix.util.Include( "cl_plugin.lua" )
ix.util.Include( "sv_plugin.lua" )

ix.util.Include( "hooks/cl_hooks.lua" )
ix.util.Include( "hooks/sh_hooks.lua" )

ix.util.Include( "meta/cl_character.lua" )
ix.util.Include( "meta/sv_character.lua" )
ix.util.Include( "meta/sh_character.lua" )

ix.char.RegisterVar("skillXP", {
    default = {},
    isLocal = true,
    bNoDisplay = true,
    field = "skillxp",
    fieldType = ix.type.text,
    OnSet = function(character, key, value, noReplication, receiver)
        local data = character.vars.skillxp or {}
        local client = character:GetPlayer()

        data[key] = value

        Print("hey. yo.")
        if (!noReplication and IsValid(client)) then
            Print("ayo?")
            net.Start("PRP.Skills.Data")
                net.WriteUInt(character:GetID(), 32)
                net.WriteString(key)
                net.WriteType(value)
            net.Send(receiver or client)
            Print(receiver or client)
        end

        character.vars.skillxp = data
        character:DoSkillXPChanged(key, value)
    end,
    OnGet = function(character, key, default)
        local data = character.vars.skillxp or {}

        if (key) then
            if (!data) then
                return 0
            end

            local value = data[key]

            return value == nil and 0 or value
        else
            return 0 or default
        end
    end
})
