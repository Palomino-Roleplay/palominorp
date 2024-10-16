ITEM.name = "Beer"
ITEM.model = Model("models/props_junk/garbage_glassbottle003a.mdl")
ITEM.description = "Forget for a little while..."
ITEM.category = "Consumables"
ITEM.width = 1
ITEM.height = 1

ITEM.noBusiness = true

if SERVER then util.AddNetworkString( "PRP.Items.Beer.Drink" ) end

ITEM.functions.Drink = {
	OnRun = function(item)
		local client = item.player

        print( SERVER and "yeah" or "no" )

        -- @TODO: Replace with actual drinking sound
        client:EmitSound( "ambient/water/rain_drip3.wav" )

        if SERVER then
            net.Start( "PRP.Items.Beer.Drink" )
            net.Send( client )
        end

		-- client:SetHealth(math.min(client:Health() + 10, client:GetMaxHealth()))
		return true
	end
}

if CLIENT then
    net.Receive( "PRP.Items.Beer.Drink", function()
        timer.Simple( 15, function()
            -- @TODO: Change this sound, add more effects
            surface.PlaySound( "npc/combine_gunship/gunship_moan.wav" )
        end )
    end )
end