-- Functions from Realistic Police addon

Realistic_Police = Realistic_Police or {}

function Realistic_Police.Drag(ply, officer)
    if not IsValid(ply) or not IsValid(officer) then return end 
    if ply:GetPos():DistToSqr(officer:GetPos()) > 15625 then return end

    ply.WeaponRPT = ply.WeaponRPT or {}

    if not IsValid(ply:GetNetVar("draggedBy", NULL)) then 
        ply:SetNetVar("draggedBy", officer)

        if IsValid( officer:GetNetVar("dragging", NULL) ) then
            officer:GetNetVar("dragging"):SetNetVar("draggedBy", NULL)
        end

        officer:SetNetVar("dragging", ply)
    else 
        ply:SetNetVar("draggedBy", false)
        officer:SetNetVar("dragging", NULL)
    end 
end

-- Not a function from Realistic Police addon
function Realistic_Police.StopDrag(ply)
    if not IsValid(ply) then return end

    ply:SetNetVar("dragging", NULL)
    if IsValid( ply:GetNetVar( "draggedBy", false ) ) then
        ply:GetNetVar( "draggedBy" ):SetNetVar( "dragging", NULL )
    end
    ply:SetNetVar("draggedBy", false)
end

hook.Add("SetupMove", "RPT:Move", function(ply, data)
    if ply:IsHandcuffed() then 
        data:SetMaxClientSpeed( 80 )
        if data:KeyDown(IN_JUMP) then
            data:RemoveKeys(IN_JUMP)
        end
    end

    -- this hook is the hook for drag the player 
    if IsValid(ply:GetNetVar("draggedBy")) then 
        if ply:GetPos():DistToSqr(ply:GetNetVar("draggedBy"):GetPos()) < 40000 then
            if IsValid(ply:GetNetVar("draggedBy")) then
                local VectorDrag = ply:GetNetVar("draggedBy"):GetPos() - ply:GetPos()
                data:SetVelocity(Vector(VectorDrag.x*4, VectorDrag.y*4, -100))
            end
        else
            ply:SetNetVar("draggedBy", false)
        end
    end
end)