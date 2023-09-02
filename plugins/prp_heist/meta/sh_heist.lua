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

function HEIST:Init()
    self:SetAlarmState( PRP.Heist.ALARM_STATE_ARMED )
end

function HEIST:AddEntity( eEntity )
    if not IsValid( eEntity ) then return end

    self.m_tEntities = self.m_tEntities or {}
    table.insert( self.m_tEntities, eEntity )
end

PRP.Heist.Meta = HEIST