-- Functions from Realistic Police addon

Realistic_Police = Realistic_Police or {}

function Realistic_Police.Drag(pPlayer, officer)
    if not IsValid(pPlayer) or not IsValid(officer) then return end 
    if pPlayer:GetPos():DistToSqr(officer:GetPos()) > 15625 then return end

    pPlayer.WeaponRPT = pPlayer.WeaponRPT or {}

    if not IsValid(pPlayer:GetNetVar("draggedBy", NULL)) then 
        pPlayer:SetNetVar("draggedBy", officer)

        if IsValid( officer:GetNetVar("dragging", NULL) ) then
            officer:GetNetVar("dragging"):SetNetVar("draggedBy", NULL)
        end

        officer:SetNetVar("dragging", pPlayer)
    else 
        pPlayer:SetNetVar("draggedBy", false)
        officer:SetNetVar("dragging", NULL)
    end 
end

-- Not a function from Realistic Police addon
function Realistic_Police.StopDrag(pPlayer)
    if not IsValid(pPlayer) then return end

    pPlayer:SetNetVar("dragging", NULL)
    if IsValid( pPlayer:GetNetVar( "draggedBy", false ) ) then
        pPlayer:GetNetVar( "draggedBy" ):SetNetVar( "dragging", NULL )
    end
    pPlayer:SetNetVar("draggedBy", false)
end

hook.Add("SetupMove", "RPT:Move", function(pPlayer, tMoveData, tUserCmd)
    if pPlayer:IsHandcuffed() then 
        tMoveData:SetMaxClientSpeed( 80 )
        if tUserCmd:KeyDown(IN_JUMP) then
            tUserCmd:RemoveKey(IN_JUMP)
        end
    end
    
    -- this hook is the hook for drag the player 
    if IsValid(pPlayer:GetNetVar("draggedBy")) then
        -- data:ClearMovement()
        if pPlayer:GetPos():DistToSqr(pPlayer:GetNetVar("draggedBy"):GetPos()) < 40000 then
            if IsValid(pPlayer:GetNetVar("draggedBy")) then
                local VectorDrag = pPlayer:GetNetVar("draggedBy"):GetPos() - pPlayer:GetPos()
                tMoveData:SetVelocity(Vector(VectorDrag.x*4, VectorDrag.y*4, -100))
            end
        else
            pPlayer:GetNetVar("draggedBy", NULL):SetNetVar("dragging", NULL)
            pPlayer:SetNetVar("draggedBy", false)
        end
    end
end)