
ITEM.name = "Consumable Base"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A consumable item."
ITEM.category = "Consumable"
ITEM.useSound = "items/ammo_pickup.wav"

function ITEM:Use( pPlayer )
    return
end

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = {
	name = "Use",
	tip = "Use",
	icon = "icon16/add.png",
	OnRun = function( item )
        item:Use( item.player )

		return true
	end,
}