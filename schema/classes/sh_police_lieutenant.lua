CLASS.name = "Police Lieutenant"
CLASS.faction = FACTION_POLICE
CLASS.isDefault = false
CLASS.classLevel = 30
CLASS.bodygroups = "023000300"
CLASS.weapons = {"prp_batteringram", "prp_ticketbook"}
CLASS.lockerWeapons_ = {
    ["weapon_pistol"] = {
        name = "Five Seven",
        entclass = "weapon_pistol",
        ammoCap = 90,
        cost = 0,
        category = "Secondary",
        fov = 25,
        vec = Vector(2, 50, 3.3),
        model = "models/weapons/w_pistol.mdl",
    },
}

CLASS_POLICE_LIEUTENANT = CLASS.index