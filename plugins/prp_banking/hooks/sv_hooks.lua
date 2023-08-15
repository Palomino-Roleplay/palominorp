function PLUGIN:CharacterRestored( cCharacter )
    local iBankingInventoryID = cCharacter:GetData( "banking_inventory_id", false )

    if iBankingInventoryID then
        ix.inventory.Restore( iBankingInventoryID, ix.item.inventoryTypes["banking_character"].w, ix.item.inventoryTypes["banking_character"].h )
    end
end