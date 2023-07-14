CLASS.name = "Police Officer"
CLASS.faction = FACTION_POLICE
CLASS.isDefault = false
CLASS.classLevel = 5
CLASS.bodygroups = "000010000"
CLASS.weapons = {"prp_ticketbook", "khr_p226"}
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

CLASS_POLICE_OFFICER = CLASS.index