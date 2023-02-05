PRP = PRP or {}
PRP.Hints = PRP.Hints or {}
PRP.Hints.List = PRP.Hints.List or {}

-- @TODO: Remove
PRP.Hints.List = {}

function PRP.Hints.Add( sEntity, tData )
    PRP.Hints.List[sEntity] = PRP.Hints.List[sEntity] or {}
    table.insert( PRP.Hints.List[sEntity], tData )
end

PRP.Hints.Add( "prp_npc", {
    -- Text = "Press E to talk to the NPC.",
    GetText = function( eEntity )
        local oNPC = eEntity:GetNPC()
        if not oNPC then return end

        return "Press E to talk to the " .. oNPC:GetTitle( eEntity ) .. "."
    end
} )

hook.Add( "HUDPaint", "PRP.Hints.HUDPaint", function()
    local eEntity = LocalPlayer():GetEyeTrace().Entity

    if not IsValid( eEntity ) then return end

    if LocalPlayer():GetPos():DistToSqr( eEntity:GetPos() ) > 10000 then return end

    local tHints = PRP.Hints.List[eEntity:GetClass()]

    if not tHints then return end

    for _, tHint in pairs( tHints ) do
        if tHint.ShouldShow and not tHint.ShouldShow( eEntity ) then continue end

        local sText = tHint.Text
        if tHint.GetText then
            sText = tHint.GetText( eEntity )
        end

        if not sText then continue end

        draw.SimpleText( sText, "ixMenuButtonFont", ScrW() / 2 + 1, ScrH() * 0.9 + 1, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( sText, "ixMenuButtonFont", ScrW() / 2, ScrH() * 0.9, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        break
    end
end )