local PLUGIN = PLUGIN

function PLUGIN:PlayerButtonDown( pPlayer, iKey )
    if not IsFirstTimePredicted() then return end
    if iKey == KEY_B and pPlayer:HasRadio() then
        permissions.EnableVoiceChat( true )
    end
end

function PLUGIN:PlayerButtonUp( pPlayer, iKey )
    if not IsFirstTimePredicted() then return end
    if iKey == KEY_B and pPlayer:HasRadio() then
        permissions.EnableVoiceChat( false )
    end
end

function PLUGIN:PlayerStartVoice( pPlayer )
    if pPlayer == LocalPlayer() then return end

    if LocalPlayer():GetCharacter():OnSameChannel( pPlayer:GetCharacter() ) then
        pPlayer._bInRadio = true
    end
end

function PLUGIN:PlayerEndVoice( pPlayer )
    if pPlayer == LocalPlayer() then return end

    pListener:GetCharacter():OnSameChannel( pTalker:GetCharacter() )
end