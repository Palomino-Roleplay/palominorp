FACTION.name = "Police"
FACTION.description = "Very angry policemen that have a tendency to injure people."
FACTION.color = Color(20, 120, 185)
FACTION.pay = 10
FACTION.weapons = {"vs_policemod_tablet"}
FACTION.isGloballyRecognized = true

FACTION.equipmentLockerAccess = true

FACTION.hasRadio = true
FACTION.defaultRadioChannel = "Police"
FACTION.radioChannels = {
    ["Police"] = true
}

FACTION.modelBase = "models/player/icpd/cops/%s_shortsleeved.mdl"

-- FACTION.models = {
-- 	"models/police.mdl"
-- }

FACTION_POLICE = FACTION.index