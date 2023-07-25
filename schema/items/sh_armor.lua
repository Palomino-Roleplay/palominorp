ITEM.name = "Body Armor"
ITEM.description = "One-time use armor."
ITEM.model = "models/props_junk/cardboard_box001a.mdl"
ITEM.width = 2
ITEM.height = 2

ITEM.functions.Use = {
	OnRun = function(tItemTable)
		local pPlayer = tItemTable.player
        
        pPlayer:SetArmor( 100 )
        pPlayer:EmitSound( "items/itempickup.wav" )

        return true
	end,
}