local PLUGIN = PLUGIN

PLUGIN.name = "Palomino: Vehicle Dealer"
PLUGIN.author = "sil"
PLUGIN.description = ""

ix.util.Include("config/sh_vehicles.lua")
ix.util.Include("meta/sh_upgrade.lua")

-- Below is basically a copy of character Data var
net.Receive("ixCharacterVehicles", function()
    local id = net.ReadUInt(32)
    local key = net.ReadString()
    local value = net.ReadType()
    local character = ix.char.loaded[id]

    if (character) then
        character.vars.vehicles = character.vars.vehicles or {}
        character:GetData()[key] = value
    end
end)

ix.char.RegisterVar("vehicles", {
    default = {},
    field = "vehicles",
    fieldType = ix.type.text,
    isLocal = true,
    bNoDisplay = true,
    OnSet = function(character, key, value, noReplication, receiver)
        local data = character:GetData()
        local client = character:GetPlayer()

        data[key] = value

        if (!noReplication and IsValid(client)) then
            net.Start("ixCharacterVehicles")
                net.WriteUInt(character:GetID(), 32)
                net.WriteString(key)
                net.WriteType(value)
            net.Send(receiver or client)
        end

        character.vars.vehicles = data
    end,
    OnGet = function(character, key, default)
        local data = character.vars.vehicles or {}

        if (key) then
            if (!data) then
                return default
            end

            local value = data[key]

            return value == nil and default or value
        else
            return default or data
        end
    end
})