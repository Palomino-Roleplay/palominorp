ITEM.name = "Medkit"
ITEM.model = Model("models/Items/HealthKit.mdl")
ITEM.description = "There ya go, buddy."
ITEM.category = "Medkits"
ITEM.width = 2
ITEM.height = 2

ITEM.noBusiness = true

ITEM.functions.Use = {
	OnRun = function(item)
        local pPlayer = item.player

        if pPlayer:Health() >= pPlayer:GetMaxHealth() then
            pPlayer:Notify( "You're already at full health." )
            return false
        end

        pPlayer:Notify( "The medkit starts to slowly heal you over time." )

        timer.Create( "PRP.Items.Medkit.Use." .. pPlayer:SteamID(), 6, 10, function()
            if IsValid( pPlayer ) then
                pPlayer:SetHealth( math.min( pPlayer:Health() + 10, pPlayer:GetMaxHealth() ) )
            end
        end )

        return true
	end
}