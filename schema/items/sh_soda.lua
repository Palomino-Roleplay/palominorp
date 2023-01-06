ITEM.name = "Soda"
ITEM.model = Model("models/props_junk/popcan01a.mdl")
ITEM.description = "A blue can filled with some carbonated flavoured water. Delicious."
ITEM.category = "Consumables"
ITEM.width = 1
ITEM.height = 1

ITEM.noBusiness = true

ITEM.functions.Drink = {
	OnRun = function(item)
		local client = item.player

		client:SetHealth(math.min(client:Health() + 10, client:GetMaxHealth()))
		return true
	end
}