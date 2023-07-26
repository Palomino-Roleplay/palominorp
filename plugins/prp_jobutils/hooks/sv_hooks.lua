local PLUGIN = PLUGIN

util.AddNetworkString( "PRP.Job.Select" )
net.Receive( "PRP.Job.Select", function( _, pPlayer )
    -- @TODO: Check distance from NPC, whether they can actually select a job, all that stuff.

    local iFaction = net.ReadUInt( 8 )
    local iClass = net.ReadUInt( 8 )

    local cCharacter = pPlayer:GetCharacter()
    if not cCharacter then return end

    if cCharacter:GetFaction() == FACTION_PRISONER then
        pPlayer:Notify( "You cannot join a job while in prison." )
        return
    end

    local tFaction = ix.faction.Get( iFaction )
    if not tFaction then return end

    local tClass = ix.class.GetByFaction( iFaction )[iClass]
    if not tClass then return end

    -- cCharacter:KickClass()

    -- if iClass ~= cCharacter:GetClass() then
    --     local bCanSwitch, sMessage = ix.class.CanSwitchTo( pPlayer, iClass )

    --     if not bCanSwitch then
    --         pPlayer:Notify( sMessage or "You cannot join this right now." )
    --         return
    --     end
    -- end


    if iFaction ~= cCharacter:GetFaction() then
        cCharacter.vars.faction = tFaction.uniqueID
        cCharacter:SetFaction(tFaction.index)
    end

    if (tFaction.OnTransferred) then
        tFaction:OnTransferred( cCharacter )
    end

    cCharacter:SetClass( iClass )

    pPlayer:Spawn()

    pPlayer:SetModel( ix.class.Get( iClass ):GetModel( pPlayer ) )
    pPlayer:SetBodyGroups( ix.class.Get( iClass ).bodygroups or "" )

    pPlayer:Notify( "You have become a " .. tClass.name .. "!" )
end )

util.AddNetworkString( "PRP.Job.Quit" )
net.Receive( "PRP.Job.Quit", function( _, pPlayer )
    -- @TODO: Check distance from NPC, whether they can actually select a job, all that stuff.
    -- local eNPC = net.ReadEntity()

    -- if not IsValid( eNPC ) or not eNPC.IsPalominoNPC then print("oopsie woopsie") return end
    -- if eNPC:GetPos():DistToSqr(LocalPlayer():GetPos()) > 90000 then
    --     pPlayer:Notify( "You are too far away from the Job NPC." )
    --     return
    -- end 

    -- @TODO: Consider putting this shit in a helper (joining too)
    local cCharacter = pPlayer:GetCharacter()

    if not cCharacter then return end

    local tFaction = ix.faction.Get( FACTION_CITIZEN )

    local tOldClass = ix.class.Get( cCharacter:GetClass() )
    if (tOldClass.OnLeave) then
        tOldClass:OnLeave( cCharacter )
    end
    cCharacter:SetClass( nil )

    cCharacter.vars.faction = tFaction.uniqueID
    cCharacter:SetFaction(tFaction.index)

    pPlayer:SetModel( pPlayer:GetCharacter():GetModel() )

    if (tFaction.OnTransferred) then
        tFaction:OnTransferred( cCharacter )
    end

    pPlayer:Notify( "You have quit your job!" )
end )