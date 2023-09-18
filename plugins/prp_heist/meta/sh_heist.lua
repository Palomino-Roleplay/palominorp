local PLUGIN = PLUGIN

PRP.Heist = PRP.Heist or {}

local HEIST = {}

AccessorFunc( HEIST, "m_sID", "ID", FORCE_STRING )
AccessorFunc( HEIST, "m_sName", "Name", FORCE_STRING )
AccessorFunc( HEIST, "m_sCategory", "Category", FORCE_STRING )
AccessorFunc( HEIST, "m_sDescription", "Description", FORCE_STRING )

PRP.Heist.ALARM_STATE_DISARMED = 0
PRP.Heist.ALARM_STATE_ARMED = 1
PRP.Heist.ALARM_STATE_ACTIVE = 2
AccessorFunc( HEIST, "m_iAlarmState", "AlarmState", FORCE_NUMBER )

AccessorFunc( HEIST, "m_tEntities", "Entities" )
AccessorFunc( HEIST, "m_tTurrets", "Turrets" )

if SERVER then util.AddNetworkString( "PRP.Heist.NetworkTurrets" ) end

function HEIST:Init()
    self:SetAlarmState( PRP.Heist.ALARM_STATE_ARMED )
end

function HEIST:AddEntity( eEntity )
    if not IsValid( eEntity ) then return end

    self.m_tEntities = self.m_tEntities or {}
    table.insert( self.m_tEntities, eEntity )

    if eEntity:GetClass() == "npc_turret_ceiling" then
        self.m_tTurrets = self.m_tTurrets or {}
        table.insert( self.m_tTurrets, eEntity )
    end
end

if SERVER then
    -- @TODO: Ugh, good enough for now.
    function PLUGIN:CharacterLoaded( cCharacter )
        local pPlayer = cCharacter:GetPlayer()
        if not IsValid( pPlayer ) then return end

        for _, oHeist in pairs( PRP.Heist.GetAll() ) do
            local tTurrets = oHeist:GetTurrets()
            if not tTurrets then continue end
            if #tTurrets == 0 then continue end

            net.Start( "PRP.Heist.NetworkTurrets" )
                net.WriteString( oHeist:GetID() )
                net.WriteUInt( #tTurrets, 8 )
                for _, eEntity in pairs( tTurrets ) do
                    net.WriteEntity( eEntity )
                end
            net.Send( pPlayer )
        end
    end
elseif CLIENT then
    net.Receive( "PRP.Heist.NetworkTurrets", function()
        local sHeistID = net.ReadString()
        local oHeist = PRP.Heist.Get( sHeistID )

        local iCount = net.ReadUInt( 8 )
        for i = 1, iCount do
            local eEntity = net.ReadEntity()
            if not IsValid( eEntity ) then continue end

            oHeist:AddEntity( eEntity )
        end
    end )
end

PRP.Heist.Meta = HEIST