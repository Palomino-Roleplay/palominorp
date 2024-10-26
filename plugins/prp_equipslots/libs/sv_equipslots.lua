local PLUGIN = PLUGIN

PRP.EquipSlots = PRP.EquipSlots or {}

do
    for sInventoryID, tInventory in pairs( PRP.EquipSlots.Inventories ) do
        ix.inventory.Register( sInventoryID, tInventory.w, tInventory.h, false )
    end
end

function PRP.EquipSlots.CreateInventory( pPlayer, cCharacter )
    Print( "Creating equipment inventories for " .. cCharacter:GetName() .. "(" .. cCharacter:GetID() .. ")" )

    for sInventoryID, tInventory in pairs( PRP.EquipSlots.Inventories ) do
        ix.inventory.New(cCharacter:GetID(), sInventoryID, function( oInventory )
            oInventory:AddReceiver( pPlayer )
            oInventory:Add( "palopal" )
            oInventory:Sync( pPlayer )

            Print( sInventoryID .. ": " .. oInventory:GetID() )
            cCharacter:SetData( sInventoryID, oInventory:GetID() )
        end )
    end
end

function PLUGIN:OnCharacterCreated( pPlayer, cCharacter )
    PRP.EquipSlots.CreateInventory( pPlayer, cCharacter )
end

function PLUGIN:CharacterLoaded( cCharacter )
    local pPlayer = cCharacter:GetPlayer()

    if not pPlayer then return end

    for sInventoryID, tInventory in pairs( PRP.EquipSlots.Inventories ) do
        local iInventoryID = cCharacter:GetData( sInventoryID )

        if iInventoryID then
            ix.inventory.Restore( iInventoryID, PRP.EquipSlots.Inventories[sInventoryID].w, PRP.EquipSlots.Inventories[sInventoryID].h, function( oInventory )
                oInventory:AddReceiver( pPlayer )
                oInventory:Sync( pPlayer )

                Print( sInventoryID .. ": " .. oInventory:GetID() )
            end )
        else
            PRP.EquipSlots.CreateInventory( pPlayer, cCharacter )
        end
    end
end

function PLUGIN:InventoryItemAdded( oFromInventory, oToInventory, oItem )
    if oToInventory and oToInventory.vars and oToInventory.vars.isBag and PRP.EquipSlots.Inventories[oToInventory.vars.isBag] then
        Print( "NEW EQUIPPED: " .. oToInventory.vars.isBag )

        if oItem.Equip then
            oItem:Equip( oToInventory:GetOwner() )
        end
    elseif oFromInventory and oFromInventory.vars and oFromInventory.vars.isBar and PRP.EquipSlots.Inventories[oFromInventory.vars.isBag] then
        Print( "NEW UNEQUIPPED: " .. oFromInventory.vars.isBag )

        if oItem.Unequip then
            oItem:Unequip( oFromInventory:GetOwner(), true )
        end
    end
end