local PLUGIN = PLUGIN

local PLY = FindMetaTable("Player")

function PLY:DeathSpawn()
    Print( "Death Spawn!" )

    self:Spawn()
    self:SetPos( table.Random( PLUGIN.spawns ) )
    self:SetHealth( 1 )
    self:StartRecovery( 30 )
end

local tRecoveringPlayers = {}
function PLY:StartRecovery( iDuration )
    self:SetLocalVar( "recoveryTimeEnd", CurTime() + iDuration )
    self:SetLocalVar( "recoveryTimeDuration", iDuration )

    table.insert( tRecoveringPlayers, self )
end

function PLY:StopRecovery()
    self:SetLocalVar( "recoveryTimeEnd", false )
    self:SetLocalVar( "recoveryTimeDuration", false )

    table.RemoveByValue( tRecoveringPlayers, self )
end

local iTimerDelta = 5
function PLUGIN:InitializedPlugins()
    if timer.Exists( "PRP.Recovery.Timer" ) then
        timer.Remove( "PRP.Recovery.Timer" )
    end

    timer.Create( "PRP.Recovery.Timer", iTimerDelta, 0, function()
        for k, v in pairs( tRecoveringPlayers ) do
            Print( v )
            if not IsValid( v ) then
                table.remove( tRecoveringPlayers, k )
                continue
            end

            local iTimeEnd = v:GetLocalVar( "recoveryTimeEnd", false )
            local iTimeDuration = v:GetLocalVar( "recoveryTimeDuration", false )
            if not iTimeEnd or not iTimeDuration then
                table.remove( tRecoveringPlayers, k )
                continue
            end

            local iTimeLeft = iTimeEnd - CurTime()
            if iTimeLeft <= 0 then
                v:StopRecovery()
                continue
            end

            -- @TODO: Sometimes doesn't recovery to full health
            local iMaxHealth = v:GetMaxHealth()
            local iNewHealth = math.Approach( v:Health(), iMaxHealth, math.ceil( iMaxHealth / ( iTimeDuration / iTimerDelta ) ) )
            v:SetHealth( iNewHealth )
        end
    end )
end