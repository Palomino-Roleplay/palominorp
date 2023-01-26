ix.class = ix.class or {}

print("hewwo?")

function ix.class.GetByFaction( faction )
    -- @TODO: Optimize
    local tReturns = {}
    for k, v in pairs(ix.class.list) do
        if (v.faction == faction) then
            tReturns[v.index] = v
        end
    end

    return tReturns
end 

-- @TODO: Remove the weird TDM car hooks