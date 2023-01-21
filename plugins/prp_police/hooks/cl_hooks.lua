local PLUGIN = PLUGIN

function PLUGIN:CanPlayerViewInventory()
    if LocalPlayer():GetCharacter():IsArrested() then return false end
end

function PLUGIN:GetCharacterName( pSpeaker, sChatType )
    if LocalPlayer():GetCharacter():IsPolice() and ( sChatType == "911" ) then
        surface.PlaySound( "npc/overwatch/radiovoice/reinforcementteamscode3.wav" )

        PRP.Police.AddCall( pSpeaker )

        return pSpeaker:GetCharacter():GetName()
    end
end