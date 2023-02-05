PRP = PRP or {}
PRP.Util = PRP.Util or {}

function PRP.Util.GetModelBase( sModel )
    return string.match( sModel, "female_%d%d" ) or string.match( sModel, "male_%d%d" ) or false
end

local PLY = FindMetaTable( "Player" )

function PLY:GetModelBase()
    return PRP.Util.GetModelBase( self:GetModel() )
end

function PLY:GetSex()
    return ( string.match( self:GetModel(), "female_%d%d" ) and "female" )
        or ( string.match( self:GetModel(), "male_%d%d" ) and "male" )
        or "unknown"
end

function PRP.Util.ApplyModelBase( sModel, pPlayer )
    return string.format( sModel, PRP.Util.GetModelBase( pPlayer:GetModel() ) )
end