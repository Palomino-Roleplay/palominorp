local PLUGIN = PLUGIN

function PLUGIN:PlayerCanHearPlayersVoice( pListener, pTalker )
    if not pTalker._bInRadio then return end
    if not pListener:GetCharacter() or not pTalker:GetCharacter() then return end
    if not pListener:IsValid() or not pTalker:IsValid() then return end
    if not pListener:Alive() or not pTalker:Alive() then return end
    if not pListener:HasRadio() or not pTalker:HasRadio() then return end

    -- @TODO: Optimize. Cache it instead of checking every time.
    if pListener:OnSameChannel( pTalker ) then
        return true, false
    end
end

function PLUGIN:PlayerButtonDown( pPlayer, iKey )
    if not IsFirstTimePredicted() then return end
    if not pPlayer:HasRadio() then return end

    if iKey == KEY_B then
        pPlayer._bInRadio = true
        pPlayer:SetNWBool( "bInRadio", true )
        pPlayer:EmitSound( "npc/metropolice/vo/on1.wav", 60 )
        pPlayer:SelectWeightedSequence( ACT_GMOD_IN_CHAT )
    end
end

function PLUGIN:PlayerButtonUp( pPlayer, iKey )
    if not IsFirstTimePredicted() then return end
    if not pPlayer:HasRadio() then return end

    if iKey == KEY_B then
        pPlayer._bInRadio = false
        pPlayer:SetNWBool( "bInRadio", false)
        pPlayer:EmitSound( "npc/metropolice/vo/on1.wav", 60, 66.6 )
    end
end