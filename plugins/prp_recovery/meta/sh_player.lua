local PLUGIN = PLUGIN

local PLY = FindMetaTable( "Player" )

function PLY:IsInHospital()
    return self:GetPos():WithinAABox( PLUGIN.hospital[1], PLUGIN.hospital[2] )
end