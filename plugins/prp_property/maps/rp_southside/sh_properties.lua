local PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

PROPERTY:SetID( "pd" )
PROPERTY:SetName( "Police Department" )
PROPERTY:SetFactions( {
    FACTION_POLICE
} )
PROPERTY:SetBounds(
    {
        {
            Vector(7423.96875,6656.1533203125,959.80999755859),
            Vector(9966.9873046875,9578.9296875,-636.59881591797),
        }
    }
)
PROPERTY:SetLockOnStart( true )
PROPERTY:SetPublicDoors( {
    -- PD Front doors
    [2926] = true,
    [2927] = true,

    -- PD gate doors,
    [2953] = true,
    [2957] = true,

    -- Elevator doors
    [3026] = true,
    [3027] = true,

    -- Elevator outside doors
    [2949] = true,
    [2950] = true,
    [2930] = true,
    [2931] = true,
    [2951] = true,
    [2952] = true,
} )

PRP.Property.Register( PROPERTY )
PROPERTY:Init()