local PLUGIN = PLUGIN

function PLUGIN:CanPlayerViewInventory()
    if LocalPlayer():GetCharacter():IsArrested() then return false end
end