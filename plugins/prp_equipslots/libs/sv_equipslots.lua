local PLUGIN = PLUGIN

PRP.EquipSlots = PRP.EquipSlots or {}

do
    for sInventoryID, tInventory in pairs( PRP.EquipSlots.Inventories ) do
        ix.inventory.Register( sInventoryID, tInventory.w, tInventory.h, false )
    end
end

function PRP.EquipSlots.CreateInventory( iCharacterID )
    for sInventoryID, tInventory in pairs( PRP.EquipSlots.Inventories ) do
        ix.inventory.New(iCharacterID, sInventoryID, function( oInventory)
            oInventory:AddReceiver( oInventory:GetOwner() )
            oInventory:Add( "palopal" )
            oInventory:Sync( oInventory:GetOwner() )

            Print( sInventoryID .. ": " .. oInventory:GetID() )
        end )
    end
end

function PLUGIN:InventoryItemAdded( oFromInventory, oToInventory, oItem )
    if oToInventory and PRP.EquipSlots.Inventories[oToInventory.vars.isBag] then
        Print( "NEW EQUIPPED: " .. oToInventory.vars.isBag )

        if oItem.Equip then
            oItem:Equip( oToInventory:GetOwner() )
        end
    elseif oFromInventory and PRP.EquipSlots.Inventories[oFromInventory.vars.isBag] then
        Print( "NEW UNEQUIPPED: " .. oFromInventory.vars.isBag )

        if oItem.Unequip then
            oItem:Unequip( oFromInventory:GetOwner(), true )
        end
    end
end