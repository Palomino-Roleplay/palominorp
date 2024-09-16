local PLUGIN = PLUGIN

print("sv_equipslots.lua")

PRP.EquipSlots = PRP.EquipSlots or {}

ix.inventory.Register("equipment", 3, 5, false)

function PRP.EquipSlots.CreateInventory( iCharacterID )
    ix.inventory.New(iCharacterID, "equipment", function( oInventory)
        -- oInventory:SetOwner( iCharacterID, true )
        -- oInventory.vars.isBag = nil
        oInventory:Add( "palopal" )
        oInventory:AddReceiver( oInventory:GetOwner() )
        Print( oInventory )
        Print( oInventory:GetID() )
    end )
end

function PLUGIN:InventoryItemAdded( oFromInventory, oToInventory, oItem )
    -- Print( "TRANSFER: " )
    -- oFromInventory:PrintAll()
    -- oToInventory:PrintAll()

    if oToInventory and oToInventory.vars.isBag == "equipment" then
        Print( "NEW EQUIPPED" )
    elseif oFromInventory and oFromInventory.vars.isBag == "equipment" then
        Print( "NEW UNEQUIPPED" )
    end
end