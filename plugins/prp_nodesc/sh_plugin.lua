local PLUGIN = PLUGIN

PLUGIN.name = "No Descriptions"
PLUGIN.author = "sil"
PLUGIN.description = "Removes character descriptions"

ix.char.vars["description"].OnValidate = nil
ix.char.vars["description"].OnPostSetup = nil
ix.char.vars["description"].bNoDisplay = true
ix.config.stored["minDescriptionLength"] = nil

function PLUGIN:GetCharacterName(client, chatType)
    if (client != LocalPlayer()) then
        local character = client:GetCharacter()
        local ourCharacter = LocalPlayer():GetCharacter()

        if (ourCharacter and character and !ourCharacter:DoesRecognize(character) and !hook.Run("IsPlayerRecognized", client)) then
            return L"unknown"
        end
    end
end