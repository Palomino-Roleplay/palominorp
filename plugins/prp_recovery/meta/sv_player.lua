local PLUGIN = PLUGIN

local PLY = FindMetaTable("Player")

function PLY:DeathSpawn()
    self:Spawn()

    self:SetHealth( 1 )
    self:Uncuff()

    local bWheelchairSpawn = ix.config.Get( "wheelchairSpawn", false )
    local iRecoveryTime = ix.config.Get( "recoveryTime", 30 )

    if bWheelchairSpawn then
        local eVehicle, sErrorMessage = PRP.Vehicle.Parking.Spawn( "hospital_wheelchairs", "wheelchair" )

        if eVehicle then
            self:EnterVehicle( eVehicle )
            self.bWheelchairSpawn = true
            self:StartRecovery( iRecoveryTime )
            return
        else
            ErrorNoHalt( "Wheelchair spawn failed: " .. ( sErrorMessage or eVehicle ) )
        end
    end

    -- @TODO: We should probably get more robust backup spawning (esp if wheelchair spawning breaks)
    self:StartRecovery( iRecoveryTime )
    self:SetPos( table.Random( PLUGIN.spawns ) )
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

    if self.bWheelchairSpawn then
        if self:InVehicle() then
            local eWheelchair = self:GetVehicle()
            self:ExitVehicle()

            eWheelchair:Remove()
        else
            -- @TODO: Make sure we handle this.
            ErrorNoHalt( "Player " .. self:Name() .. " spawned in wheelchair but not in a vehicle after recovery ended." )
        end

        self.bWheelchairSpawn = false
    end

    table.RemoveByValue( tRecoveringPlayers, self )

    -- Ugly, but whatever.
    local oProperty = PRP.Property.Get( "hospital" )
    local tEntities = oProperty:GetEntities()
    for _, eEntity in pairs( tEntities or {} ) do
        if eEntity.m_bIsCinema then
            local oMediaPlayer = eEntity:GetMediaPlayer()
            if not oMediaPlayer then continue end
            if not oMediaPlayer:HasListener( self ) then continue end
            oMediaPlayer:RemoveListener( self )
        end
    end

    if self:IsInHospital() then
        self:SetPos( table.Random( PLUGIN.normalSpawns ) )
    end
end

local iTimerDelta = 5
function PLUGIN:InitializedPlugins()
    if timer.Exists( "PRP.Recovery.Timer" ) then
        timer.Remove( "PRP.Recovery.Timer" )
    end

    timer.Create( "PRP.Recovery.Timer", iTimerDelta, 0, function()
        for k, v in pairs( tRecoveringPlayers ) do
            if not v:IsInHospital() then continue end

            if ( not IsValid( v ) ) or ( not v:Alive() ) then
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