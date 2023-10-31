local PLUGIN = PLUGIN

PRP.Heist = PRP.Heist or {}

function PLUGIN:InitializedPlugins()
    HEIST = setmetatable( {}, { __index = PRP.Heist.Meta } )
    HEIST:SetID( "bank" )
    HEIST:SetName( "Bank" )
    HEIST:SetCategory( "major" )
    HEIST:SetDescription( "Good luck, you'll need it." )
    HEIST:SetPos( Vector( -1549, 3192, -280 ) )
    PRP.Heist.Register( HEIST )
end

function PLUGIN:InitializedProperties()
    local oHeistBank = PRP.Heist.Get( "bank" )

    -- Bank
    PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )
    PROPERTY:SetID( "bank" )
    PROPERTY:SetName( "Bank" )
    -- PROPERTY:SetPermaProps( {
    --     { pos = Vector( -1949, 3411, -280 ), angles = Angle( 0, 11, 0 ), model = "models/props/cs_militia/crate_extrasmallmill.mdl" },
    --     { pos = Vector( -1947, 3353, -280 ), angles = Angle( 0, 0, 0 ), model = "models/props/cs_militia/crate_extrasmallmill.mdl" },
    --     { pos = Vector( -1949, 3353, -231 ), angles = Angle( 0, 0, 0 ), model = "models/props/cs_militia/crate_extrasmallmill.mdl" },
    -- } )
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
        eEntity:SetHeist( oHeistBank )
        -- eEntity:SetTerminal( "security" )

        eEntity.OnSuccess = function( this )
            PRP.Heist.Southside.ToggleOuterDoors()
        end
    end )
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -410, 2503, -104 ), Angle( 0, -180, 0 ), function( eEntity )
        eEntity:SetHeist( oHeistBank )
        -- eEntity:SetTerminal( "lasers" )

        eEntity.OnSuccess = function( this )
            PRP.Heist.Southside.ToggleBankLasers()
        end
    end )
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -1221, 3322, -280 ), Angle( 0, 0, 0 ), function( eEntity )
        eEntity:SetHeist( oHeistBank )
        -- eEntity:SetTerminal( "vault_1" )
    end )
    PROPERTY:AddSpawnEntity( "prp_heist_terminal", Vector( -1221, 3073, -280 ), Angle( 0, 0, 0 ), function( eEntity )
        eEntity:SetHeist( oHeistBank )
        -- eEntity:SetTerminal( "vault_2" )
    end )

    -- Buttons
    PROPERTY:AddSpawnEntity( "prp_heist_button", Vector( -585, 2559, -45 ), Angle( 90, 90, 180 ), function( eEntity )
        eEntity:SetHeist( oHeistBank )
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
        -- eEntity:SetHeist( oHeistBank )
        eEntity:SetKeyValue( "SquadName", "bank" )

        oHeistBank:AddEntity( eEntity )

        local iSpawnFlags = bit.bor( SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK )
        iSpawnFlags = bit.bor( iSpawnFlags, 32 )
        eEntity:SetKeyValue( "spawnflags", iSpawnFlags )
        eEntity.SpawnFlags = iSpawnFlags
    end
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1865, 3008, -120 ), Angle( 0, 64, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1773, 3008, -120 ), Angle( 0, 128, 0 ), fnTurretCallback )

    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1730, 3361, -120 ), Angle( 0, 180, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1759, 3446, -120 ), Angle( 0, 224, 0 ), fnTurretCallback )
    PROPERTY:AddSpawnEntity( "npc_turret_ceiling", Vector( -1844, 3449, -120 ), Angle( 0, 271, 0 ), fnTurretCallback )

    PROPERTY:AddSpawnEntity( "prp_heist_switch", Vector( -1654, 3251, -217 ), Angle( 0, -90, 0 ), function( eEntity )
        eEntity:SetHeist( oHeistBank )
    end )

    PRP.Property.Register( PROPERTY )
end