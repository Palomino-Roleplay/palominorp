FACTION.name = "Police"
FACTION.description = "Very angry policemen that have a tendency to injure people."
FACTION.color = Color(20, 120, 185)
FACTION.pay = 10
FACTION.weapons = {"prp_handcuffs", "prp_tazer"}
FACTION.attachments = {"md_rmr", "md_insight_x2", "md_eotech"}
FACTION.isGloballyRecognized = true

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