local PLUGIN = PLUGIN

local tRemoveEnts = {
    [3070] = true,
    [3071] = true,
    [3042] = true,
    [3041] = true,
    [3044] = true,
    [3043] = true,
    [3040] = true,
    [3039] = true,
    [3037] = true,
    [3038] = true,
    [3035] = true,
    [3036] = true,
    [3069] = true,
    [3068] = true,
    [3073] = true,
    [3072] = true,
    [3054] = true,
    [3055] = true,
    [3056] = true,
    [3057] = true,
    [3053] = true,
    [3052] = true,
    [3051] = true,
}

function PLUGIN:InitPostEntity()
    for _, eEntity in pairs(ents.GetAll()) do
        if not IsValid( eEntity ) then continue end
        if tRemoveEnts[eEntity:MapCreationID()] then eEntity:Remove() end
    end

    PRP.Vehicle.Parking.Register( "hospital_wheelchairs", {
        Spots = {
            {
                min = Vector(7514.3764648438,5635.443359375,224.03125),
                max = Vector(7451.5278320313,5747.845703125,292.61761474609),
                ang = Angle(0, -180, 0),
            },
            {
                min = Vector(7432.1284179688,5635.5170898438,224.03125),
                max = Vector(7369.1889648438,5743.96875,292),
                ang = Angle(0, -180, 0),
            },
            {
                min = Vector(7612.3793945313,5638.634765625,224.03125),
                max = Vector(7682.3969726563,5743.96875,292),
                ang = Angle(0, -180, 0),
            },
            {
                min = Vector(7447.84375,5613.7900390625,224.03125),
                max = Vector(7377.8662109375,5510.5981445313,292),
                ang = Angle(0, -180, 0),
            },
            {
                min = Vector(7467.3618164063,5608.8041992188,224.03125),
                max = Vector(7537.330078125,5510.78515625,292),
                ang = Angle(0, -180, 0),
            },
            {
                min = Vector(7620.4262695313,5515.9555664063,292),
                max = Vector(7566.2368164063,5601.8745117188,224.03125),
                ang = Angle(0, -180, 0),
            },
            {
                min = Vector(7715.5869140625,5604.720703125,224.03125),
                max = Vector(7649.17578125,5510.8920898438,292),
                ang = Angle(0, -180, 0),
            },
        }
    } )
end