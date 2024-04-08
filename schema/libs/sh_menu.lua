ix.menu = ix.menu or {}
ix.menu.registered = ix.menu.registered or {}

-- Example:
-- ix.menu.RegisterOption( ENT, "I'm Amazing", {
-- 	OnCanRun = function()
-- 		print("I'm run on the server AND the client.")
-- 	end,
-- 	OnRun = function( eEntity, pPlayer, sOption, tData )
-- 		print("I'm only run on the server")
-- 	end,
-- } )

-- This overrides GetEntityMenu. Don't use it in functions where you use this.

local function GetEntityMenu( eEntity )
    local tOptions = eEntity:IsPlayer() and {} or ( eEntity._oldGetEntityMenu and eEntity:_oldGetEntityMenu( LocalPlayer() ) or {} )
    local tRegisteredOptions = ix.menu.registered[eEntity:IsVehicle() and "vehicle" or eEntity:GetClass()]

    if ( tRegisteredOptions ) then
        for k, v in pairs( tRegisteredOptions ) do
            if ( v.OnCanRun and v.OnCanRun( eEntity, LocalPlayer() ) == false ) then continue end
            tOptions[k] = v.OnRun
        end
    end

    return tOptions
end

function ix.menu.RegisterOption( tEntityTable, sOption, tData )
    ix.menu.registered[tEntityTable.ClassName] = ix.menu.registered[tEntityTable.ClassName] or {}
    ix.menu.registered[tEntityTable.ClassName][sOption] = tData

    tEntityTable["OnSelect"..sOption:gsub("%s", "")] = tData.OnRun

    -- Helix is weird. We need these for the hooks to run so we can show the menu in the first place.
    if CLIENT then
        tEntityTable._oldGetEntityMenu = tEntityTable._oldGetEntityMenu or tEntityTable.GetEntityMenu
        tEntityTable.GetEntityMenu = tEntityTable.GetEntityMenu or GetEntityMenu
    end
    tEntityTable.OnOptionSelected = tEntityTable.OnOptionSelected or function() end
end

local PLY = FindMetaTable( "Player" )
function ix.menu.RegisterPlayerOption( sOption, tData )
    ix.menu.registered["player"] = ix.menu.registered["player"] or {}
    ix.menu.registered["player"][sOption] = tData

    PLY["OnSelect"..sOption:gsub("%s", "")] = tData.OnRun
end

local VEHICLE = FindMetaTable( "Vehicle" )
function ix.menu.RegisterVehicleOption( sOption, tData )
    -- @TODO: Maybe another table for vehicles?
    ix.menu.registered["vehicle"] = ix.menu.registered["vehicle"] or {}
    ix.menu.registered["vehicle"][sOption] = tData

    VEHICLE["OnSelect"..sOption:gsub("%s", "")] = tData.OnRun
end

function VEHICLE:GetEntityMenu( pPlayer )
    -- @TODO: Remove the damn ALT+SHIFT thing in helix.
    return not pPlayer:InVehicle() and pPlayer:KeyDown( IN_WALK ) and GetEntityMenu( self )
end

hook.Add( "GetPlayerEntityMenu", "PRP.EntMenu.GetPlayerEntityMenu", function( pPlayer, tOptions )
    table.Merge( tOptions, GetEntityMenu( pPlayer ) )
end )

hook.Add( "PlayerUse", "PRP.EntMenu.PlayerUse", function( pPlayer, eEntity )
    if eEntity:IsVehicle() and pPlayer:KeyDown( IN_WALK ) then
        return false
    end
end )

hook.Add( "VC_canEnterPassengerSeat", "PRP.EntMenu.VC_canEnterPassengerSeat", function( pPlayer, eEntity, iSeat )
    if pPlayer:KeyDown( IN_WALK ) then
        return false
    end
end )

hook.Add( "CanPlayerInteractEntity", "PRP.EntMenu.CanPlayerInteractEntity", function( pPlayer, eEntity, sOption, tData )
    if ( ix.menu.registered[eEntity:GetClass()] and ix.menu.registered[eEntity:GetClass()][sOption] ) then
        local tOptionData = ix.menu.registered[eEntity:GetClass()][sOption]

        -- Allows others to add their own checks.
        if tOptionData.OnCanRun and tOptionData.OnCanRun( eEntity, pPlayer, eEntity, tData ) == false then
            return false
        end
    end
end )

if CLIENT then
    function ix.menu.Open( tOptions, eEntity )
        if (IsValid(ix.menu.panelV2)) then
            -- return false
            ix.menu.panelV2:Remove()
            ix.menu.panelV2 = nil
        end

        -- @TODO: Make a better interaction menu

        if not tOptions or table.IsEmpty(tOptions) then return false end

        Print( table.GetKeys( tOptions ) )
        PUI.Dialogue.New( eEntity, table.GetKeys( tOptions ) )

        -- ix.menu.panelV2 = DermaMenu( false )
        -- for k, v in pairs( tOptions ) do
            -- ix.menu.panelV2:AddOption( k, function()
            --     ix.menu.NetworkChoice( eEntity, k, bStatus )
            --     ix.menu.panelV2:Remove()
            --     ix.menu.panelV2 = nil
            -- end )
        -- end

        -- ix.menu.panelV2:Open( ScrW() / 2, ScrH() / 2 )
        -- input.SetCursorPos( ScrW() / 2, ScrH() / 2 )

        return true
    end
end