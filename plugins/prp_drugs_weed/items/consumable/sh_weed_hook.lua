
ITEM.name = "Drying Rack Hooks"
ITEM.model = "models/zerochain/props_growop2/zgo2_dryline.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A set of hooks used to hang weed on a drying rack."
ITEM.category = "Weed"
ITEM.useSound = "items/ammo_pickup.wav"

function ITEM:Use( pPlayer )
    if CLIENT then return end

    -- @TODO: Ensure players can't use it multiple times and waste it.

    pPlayer:Give( "prp_weed_hook" )
end