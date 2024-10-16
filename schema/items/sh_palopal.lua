ITEM.name = "Palo-pal"
ITEM.model = Model("models/maxofs2d/companion_doll.mdl")
ITEM.description = "A small doll to keep you company when you're feeling lonely."
ITEM.category = "Collectables"
ITEM.width = 1
ITEM.height = 1

ITEM.noBusiness = true

ITEM.functions.Hug = {
	OnRun = function(item)
        local pPlayer = item.player

        pPlayer._palopal_nextHug = pPlayer._palopal_nextHug or 0

		if pPlayer._palopal_nextHug and pPlayer._palopal_nextHug > CurTime() then
            if pPlayer._palopal_lastHugHurt then
                pPlayer:Notify( "You hug the doll cautiously. Luckily it doesn't respond." )
            else
                pPlayer:Notify( "You hug the doll, but it doesn't feel the same..." )
            end
            return false
        end

        pPlayer._palopal_nextHug = CurTime() + 1800

        if math.random() < 0.05 then
            pPlayer:EmitSound( "npc/headcrab/attack3.wav" )
            pPlayer:Notify( "The doll bites you! Ouch..." )
            pPlayer:TakeDamage( 5, pPlayer, pPlayer )
            pPlayer._palopal_lastHugHurt = true

            -- @TODO: Make the player frown
        else
            pPlayer:EmitSound( "npc/headcrab/idle2.wav", 75, 100 )
            pPlayer:Notify( "You embrace the doll, and a warm, fuzzy feeling envelops you." )
            pPlayer:SetHealth( math.min( pPlayer:Health() + 2, pPlayer:GetMaxHealth() ) )
            pPlayer._palopal_lastHugHurt = false

            -- @TODO: Make the player smile
        end

        return false
	end
}