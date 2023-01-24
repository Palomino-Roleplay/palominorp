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
-- @TODO: Actually it might not have to ^
-- @TODO: Investigate why all this only works after autorefresh

function ix.menu.RegisterOption( tEntityTable, sOption, tData )
    ix.menu.registered[tEntityTable.ClassName] = ix.menu.registered[tEntityTable.ClassName] or {}
    ix.menu.registered[tEntityTable.ClassName][sOption] = tData

    tEntityTable["OnSelect"..sOption:gsub("%s", "")] = tData.OnRun

    -- Helix is weird. We need these for the hooks to run so we can show the menu in the first place.
    tEntityTable.GetEntityMenu = tEntityTable.GetEntityMenu or function( self ) return {} end
    tEntityTable.OnOptionSelected = tEntityTable.OnOptionSelected or function() end
end

function ix.menu.RegisterPlayerOption( sOption, tData )
    ix.menu.registered["player"] = ix.menu.registered["player"] or {}
    ix.menu.registered["player"][sOption] = tData
end

hook.Add( "CanPlayerInteractEntity", "PRP.EntMenu.CanPlayerInteractEntity", function( pPlayer, eEntity, sOption, tData )
    if ( ix.menu.registered[eEntity:GetClass()] and ix.menu.registered[eEntity:GetClass()][sOption] ) then
        local tOptionData = ix.menu.registered[eEntity:GetClass()][sOption]
        local bCanRun = true

        if ( tOptionData.OnCanRun ) then
            bCanRun = tOptionData.OnCanRun( pPlayer, eEntity, tData )
        end

        -- Allows others to add their own checks.
        if not bCanRun then
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

        ix.menu.panelV2 = DermaMenu( false )
        for k, v in pairs( tOptions ) do
            ix.menu.panelV2:AddOption( k, function()
                ix.menu.NetworkChoice( eEntity, k, bStatus )
                ix.menu.panelV2:Remove()
                ix.menu.panelV2 = nil
                gui.EnableScreenClicker( false )
            end )
        end
        gui.EnableScreenClicker( true )
        ix.menu.panelV2:Open()

        RegisterDermaMenuForClose( ix.menu.panelV2 )

        return true
    end

    function Schema:ShowEntityMenu( eEntity )
        local tOptions = eEntity:GetEntityMenu( LocalPlayer() ) or {}
        local tRegisteredOptions = ix.menu.registered[eEntity:GetClass()]

        if ( tRegisteredOptions ) then
            for k, v in pairs( tRegisteredOptions ) do
                if ( v.OnCanRun and not v.OnCanRun( LocalPlayer(), eEntity ) ) then continue end
                tOptions[k] = v.OnRun
            end
        end

        if (istable(tOptions) and !table.IsEmpty(tOptions)) then
            ix.menu.Open(tOptions, eEntity)
        end
    end
end