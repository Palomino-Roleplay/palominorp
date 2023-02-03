local PLUGIN = PLUGIN

local PLY = FindMetaTable( "Player" )

function PLY:IsHandcuffed()
    -- @TODO: Return true only when handcuffed, not tied. (look at weapon maybe)
    -- @TODO: Remove self:HasWeapon check
    return self:GetNetVar( "handcuffed", false ) or self:HasWeapon( "prp_cuffed" )
end

function PLY:IsDragged()
    return IsValid( self:GetNetVar("draggedBy", NULL) )
end

function PLY:GetDragged()
    return self:GetNetVar("draggedBy", NULL)
end


function PLY:IsDragging()
    return IsValid( self:GetNetVar("dragging", NULL) )
end

function PLY:GetDragging()
    return self:GetNetVar("dragging", NULL)
end