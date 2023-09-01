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
        -- @TODO: Update for rp_southside_day
        -- -- PD Front doors
        -- [2926] = true,
        -- [2927] = true,

        -- -- PD gate doors,
        -- [2953] = true,
        -- [2957] = true,

        -- -- Elevator doors
        -- [3026] = true,
        -- [3027] = true,

        -- -- Elevator outside doors
        -- [2949] = true,
        -- [2950] = true,
        -- [2930] = true,
        -- [2931] = true,
        -- [2951] = true,
        -- [2952] = true,
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

    -- White edge warehouse
    -- Warehouse Complex on Any Way
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

    PROPERTY:SetID( "warehouse_1" )
    PROPERTY:SetName( "Warehouse 1" )
    PROPERTY:SetRentable( true )
    PROPERTY:SetLockOnStart( true )
    PROPERTY:SetRent( 10 )
    PROPERTY:SetFloorZ( -104 )

    PROPERTY:SetBounds(
        {
            {
                Vector(7199.9677734375,-2527.96875,-104),
                Vector(6207.99609375,-991.96875,336),
            }
        }
    )
    PROPERTY:SetZones(
        {
            {
                type = "prop_blacklist",
                pos = {
                    Vector(6400.7841796875,-980.6396484375,-104),
                    Vector(7049.625,-1257.7608642578,201),
                }
            },
        }
    )
    PRP.Property.Register( PROPERTY )

    -- Old Taxi Depot
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

    PROPERTY:SetID( "warehouse_2" )
    PROPERTY:SetName( "Warehouse 2" )
    PROPERTY:SetRentable( true )
    PROPERTY:SetLockOnStart( true )
    PROPERTY:SetRent( 10 )
    PROPERTY:SetFloorZ( -32 )

    PROPERTY:SetBounds(
        {
            {
                Vector(-4095.96875,3967.9140625,-40),
                Vector(-5247.7553710938,2943.96875,344),
            }
        }
    )
    PROPERTY:SetZones(
        {
            {
                type = "prop_blacklist",
                pos = {
                    Vector(-5248.03125,2943.9497070313,-40),
                    Vector(-4942.2446289063,3935.96875,259),
                }
            },
        }
    )
    PRP.Property.Register( PROPERTY )

    -- Hospital
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )
    PROPERTY:SetID( "hospital" )
    PROPERTY:SetName( "Hospital" )
    PROPERTY:SetRentable( false )
    PROPERTY:SetLeasable( false )
    PROPERTY:SetPublicDoors( {
        [3026] = true,
        [3027] = true,
    } )
    PROPERTY:SetBounds(
        {
            {
                Vector( 6400, 4863, -63 ),
                Vector( 8128, 5760, 736 )
            }
        }
    )
    PROPERTY:AddZone( {
        type = "cinema_public",
        name = "Room 202",
        pos = {
            Vector( 7664, 4592, 224),
            Vector( 7936, 4832, 368 )
        },
        screen = {
            class = "mediaplayer_tv",
            pos = Vector( 7790, 4603, 224 ),
            ang = Angle( 0, 90, 0 ),
        },
    } )
    PROPERTY:AddZone( {
        type = "cinema_public",
        name = "Room 204",
        pos = {
            Vector( 7520, 4832, 224 ),
            Vector( 7280, 4592, 368 )
        },
        screen = {
            class = "mediaplayer_tv",
            pos = Vector( 7408, 4603, 224 ),
            ang = Angle( 0, 90, 0 ),
        },
    } )
    PROPERTY:AddZone( {
        type = "cinema_public",
        name = "Room 202",
        pos = {
            Vector( 7664, 4592, 224),
            Vector( 7936, 4832, 368 )
        },
        screen = {
            class = "mediaplayer_tv",
            pos = Vector( 7790, 4603, 224 ),
            ang = Angle( 0, 90, 0 ),
        },
    } )
    PROPERTY:AddZone( {
        type = "cinema_playlist",
        name = "Room 201",
        pos = {
            Vector( 7776, 5008, 224 ),
            Vector( 8112, 5744, 368 )
        },
        screen = {
            class = "mediaplayer_tv",
            pos = Vector( 7829, 5384, 224 ),
            ang = Angle( 0, -42, 0 ),
        },
    } )
    PROPERTY:SetLockOnStart( true )
    -- PROPERTY:AddSpawnEntity( "mediaplayer_tv", Vector( 7790, 4603, 224 ), Angle( 0, 90, 0 ) )
    -- PROPERTY:AddSpawnEntity( "mediaplayer_tv", Vector( 7408, 4603, 224 ), Angle( 0, 90, 0 ) )
    -- PROPERTY:AddSpawnEntity( "mediaplayer_tv", Vector( 7026, 4603, 224 ), Angle( 0, 90, 0 ) )
    -- PROPERTY:AddSpawnEntity( "mediaplayer_tv", Vector( 6534, 4931, 224 ), Angle( 0, 0, 0 ) )
    -- PROPERTY:AddSpawnEntity( "mediaplayer_tv", Vector( 7829, 5384, 224 ), Angle( 0, -42, 0 ) )
    PRP.Property.Register( PROPERTY )

    -- Bank
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )
    PROPERTY:SetID( "bank" )
    PROPERTY:SetName( "Bank" )
    PROPERTY:SetPermaProps( {
        { pos = Vector( -1949, 3411, -280 ), angles = Angle( 0, 11, 0 ), model = "models/props/cs_militia/crate_extrasmallmill.mdl" },
        { pos = Vector( -1947, 3353, -280 ), angles = Angle( 0, 0, 0 ), model = "models/props/cs_militia/crate_extrasmallmill.mdl" },
        { pos = Vector( -1949, 3353, -231 ), angles = Angle( 0, 0, 0 ), model = "models/props/cs_militia/crate_extrasmallmill.mdl" },
    } )
    PROPERTY:SetBounds({
        {
            Vector(-192.21844482422,2164.1379394531,512.03125),
            Vector(-1983.9479980469,3551.96875,-279.94430541992),
        },
        {
            Vector(-1152.03125,3071.8728027344,703.93206787109),
            Vector(-1280.0834960938,2815.96875,512.16235351563),
        },
    })
    PROPERTY:SetLockOnStart( true )
    PROPERTY:SetPublicDoors( {
        -- Front Doors
        [3210] = true,
        [3211] = true,

        -- Outer Vault Doors
        [3112] = true,
        [3113] = true,

        -- Security Gates
        [3141] = true, -- Apparently it's just one entity lmao

        -- Vault
        [3125] = true,
    } )
    -- Terminals
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -1125, 3048, -104 ), Angle( 0, 0, 0 ), function( eEntity )
        -- eEntity:SetHeist( "bank" )
        -- eEntity:SetTerminal( "security" )

        eEntity.OnSuccess = function( this )
            PRP.Heist.Southside.ToggleOuterDoors()
        end
    end )
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -410, 2503, -104 ), Angle( 0, -180, 0 ), function( eEntity )
        -- eEntity:SetHeist( "bank" )
        -- eEntity:SetTerminal( "lasers" )

        eEntity.OnSuccess = function( this )
            PRP.Heist.Southside.ToggleBankLasers()
        end
    end )
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -1221, 3322, -280 ), Angle( 0, 0, 0 ), function( eEntity )
        -- eEntity:SetHeist( "bank" )
        -- eEntity:SetTerminal( "vault_1" )
    end )
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -1221, 3073, -280 ), Angle( 0, 0, 0 ), function( eEntity )
        -- eEntity:SetHeist( "bank" )
        -- eEntity:SetTerminal( "vault_2" )
    end )

    -- Buttons
    PROPERTY:AddSpawnEntity( "prp_heist_button", Vector( -585, 2559, -45 ), Angle( 90, 90, 180 ), function( eEntity )
        eEntity.Use = function( pPlayer )
            if not IsValid( pPlayer ) then return end

            eEntity:EmitSound( "buttons/blip1.wav", 60 )

            timer.Simple( 1, function()
                ents.GetMapCreatedEntity( 3112 ):Fire( "toggle" )
                ents.GetMapCreatedEntity( 3113 ):Fire( "toggle" )
            end )

        end
    end )

    -- Turrets
    local function fnTurretCallback( eEntity )
        eEntity:SetKeyValue( "SquadName", "bank" )

        local iSpawnFlags = bit.bor( SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK )
        iSpawnFlags = bit.bor( iSpawnFlags, 32 )
        eEntity:SetKeyValue( "spawnflags", iSpawnFlags )
        eEntity.SpawnFlags = iSpawnFlags
    end
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1865, 3008, -120 ), Angle( 0, 64, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1773, 3008, -120 ), Angle( 0, 128, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1865, 3505, -120 ), Angle( 0, -64, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1773, 3505, -120 ), Angle( 0, -128, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "prp_heist_switch", Vector( -1654, 3251, -217 ), Angle( 0, -90, 0 ) )


    PRP.Property.Register( PROPERTY )
end
hook.Add( "InitPostEntity", "PRP.Property.InitPostEntity.CreateProperties", PRP.Property.RegisterProperties )

if SERVER then
    concommand.Add( "prp_properties_register", function( pPlayer )
        if not IsValid( pPlayer ) or not pPlayer:IsSuperAdmin() then return end

        PRP.Property.RegisterProperties()
    end )
end