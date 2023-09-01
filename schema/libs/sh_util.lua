PRP = PRP or {}
PRP.Util = PRP.Util or {}

function PRP.Util.GetModelBase( sModel )
    return string.match( sModel, "female_%d%d" ) or string.match( sModel, "male_%d%d" ) or false
end

-- Yeah, yeah, Color isn't supposed to be called a lot, but this'll be fine if used rarely.
-- @TODO: Move to UI library prob
function PRP.Util.LerpColor( iFraction, oFrom, oTo )
    return Color(
        Lerp( iFraction, oFrom.r, oTo.r ),
        Lerp( iFraction, oFrom.g, oTo.g ),
        Lerp( iFraction, oFrom.b, oTo.b ),
        Lerp( iFraction, oFrom.a, oTo.a )
    )
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