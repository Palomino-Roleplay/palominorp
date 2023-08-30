local PLUGIN = PLUGIN

local PLY = FindMetaTable( "Player" )

function PLY:IsInHospital()
    local oHospital = PRP.Property.Get( "hospital" )
    if not oHospital then return false end

    return oHospital:Contains( self:GetPos() )
end

function PLY:IsRecovering()
    local iRecoveryEndTime = self:GetLocalVar( "recoveryTimeEnd", false )

    if iRecoveryEndTime and iRecoveryEndTime > CurTime() then
        return true
    end

    return false
end