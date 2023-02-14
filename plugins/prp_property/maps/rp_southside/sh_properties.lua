local PLUGIN = PLUGIN

function PLUGIN:InitializedPlugins()
    local PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )
    
    -- Police Department
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
    -- PROPERTY:Init()

    print("test")

    -- Leprechauns Winklepicker (Bar)
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

    PROPERTY:SetID( "bar" )
    PROPERTY:SetName( "Leprechauns Winklepicker" )
    PROPERTY:SetRentable( true )

    PROPERTY:SetBounds(
        {
            {
                Vector(5329.5654296875,8657.2353515625,327.04516601563),
                Vector(4479.96875,7104.12109375,129.42752075195),
            }
        }
    )

    PRP.Property.Register( PROPERTY )
    -- PROPERTY:Init()
end