local PLUGIN = PLUGIN

function PLUGIN:PlayerButtonDown( pPlayer, iKey )
    if not IsFirstTimePredicted() then return end
    if iKey == KEY_B and pPlayer:HasRadio() then
        -- pPlayer._bInRadio = true
        permissions.EnableVoiceChat( true )
    end
end

function PLUGIN:PlayerButtonUp( pPlayer, iKey )
    if not IsFirstTimePredicted() then return end
    if iKey == KEY_B and pPlayer:HasRadio() then
        -- pPlayer._bInRadio = false
        permissions.EnableVoiceChat( false )
    end
end

-- TODO: Add noise that players are talking in radio.
function PLUGIN:PlayerStartVoice( pPlayer )
    return
end

function PLUGIN:PlayerEndVoice( pPlayer )
    -- if pPlayer == LocalPlayer() then return end

    -- pListener:OnSameChannel( pTalker )
end