local PLUGIN = PLUGIN or {}

net.Receive("PRP.Skills.Data", function()
    local id = net.ReadUInt(32)
    local key = net.ReadString()
    local value = net.ReadType()
    local character = ix.char.loaded[id]

    Print("test")

    if (character) then
        character.vars.skillxp = character.vars.skillxp or {}
        character.vars.skillxp[key] = value
        Print("testoooo")
    end
end)
