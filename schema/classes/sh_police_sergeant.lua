CLASS.name = "Police Sergeant"
CLASS.faction = FACTION_POLICE
CLASS.isDefault = false
CLASS.classLevel = 15
CLASS.bodygroups = "001000200"
CLASS.weapons = {"prp_batteringram", "prp_ticketbook", "khr_p226", "cw_mp7_official"}
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

CLASS_POLICE_SERGEANT = CLASS.index