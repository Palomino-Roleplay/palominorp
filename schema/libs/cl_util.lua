
local bInClientUse = false
hook.Add( "KeyPress", "PRP.Util.KeyPress", function( pPlayer, iKey )
    if iKey == IN_USE then
        if bInClientUse then return end
        bInClientUse = true

        local eEntity = pPlayer:GetEyeTrace().Entity

        if not IsValid( eEntity ) then return end
        if not eEntity.ClientUse then return end

        -- pPlayer is redundant here, but passed for consistency
        eEntity:ClientUse( pPlayer )
    elseif bInClientUse then
        bInClientUse = false
    end
end )

hook.Add( "KeyRelease", "PRP.Util.KeyRelease", function( pPlayer, iKey )
    if iKey == IN_USE then
        bInClientUse = false
    end
end )