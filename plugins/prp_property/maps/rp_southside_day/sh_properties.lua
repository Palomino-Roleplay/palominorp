local PLUGIN = PLUGIN

function PRP.Property.RegisterProperties()
    Print( "Initializing Properties..." )

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



    -- Leprechauns Winklepicker (Bar)
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

    PROPERTY:SetID( "bar" )
    PROPERTY:SetName( "Leprechauns Winklepicker" )
    PROPERTY:SetRentable( true )
    PROPERTY:SetLockOnStart( false )
    PROPERTY:SetRent( 10 )

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



    -- Warehouse Complex on Any Way
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

    PROPERTY:SetID( "warehouse_complex" )
    PROPERTY:SetName( "Warehouse Complex" )
    PROPERTY:SetRentable( true )
    PROPERTY:SetLockOnStart( true )
    PROPERTY:SetRent( 10 )
    PROPERTY:SetFloorZ( -96 )

    PROPERTY:SetBounds(
        {
            -- White Warehouse
            {
                Vector(-1759.9952392578,-2432.0393066406,-96),
                Vector(-191.96875,-1184.1264648438,343.77581787109),
            },

            -- Brick Warehouse
            {
                Vector(-2912.1110839844,-1088.0456542969,288.03125),
                Vector(-3647.7465820313,-2079.9838867188,-96),
            },

            -- Outdoor
            {
                Vector(-2911.7924804688,-1056,-96),
                Vector(-1779.9730224609,-2552.9321289063,546.9873046875),
            }
        }
    )

    -- @TODO: Consider multi vector-pair zones
    PROPERTY:SetZones(
        {
            {
                type = "prop_blacklist",
                pos = {
                    Vector(-2240,-1056,-96),
                    Vector(-2777,-1303,96),
                }
            },
            {
                type = "prop_blacklist",
                pos = {
                    Vector(-1512, -2136, 156),
                    Vector(-2035, -1461, -96),
                }
            },
            {
                type = "prop_blacklist",
                pos = {
                    Vector(-3158, -2080, 165),
                    Vector(-2709, -1148, -96),
                }
            }
        }
    )
    PRP.Property.Register( PROPERTY )
    -- PROPERTY:Init()
end
hook.Add( "InitializedPlugins", "PRP.Property.InitializedPlugins.CreateProperties", PRP.Property.RegisterProperties )

if SERVER then
    concommand.Add( "prp_properties_register", function( pPlayer )
        if not IsValid( pPlayer ) or not pPlayer:IsSuperAdmin() then return end

        PRP.Property.RegisterProperties()
    end )
end