local PLUGIN = PLUGIN

PRP.Heist = PRP.Heist or {}

-- Giving players the loot
local function fnLootTransfer( pPlayer )
    -- @TODO: Shit ton of checks
    if not IsValid( pPlayer ) then return end
    Print( "Loot transfer for " .. pPlayer:GetName() )

    local iLoot = pPlayer:GetNW2Int( "PRP.Heist.Loot", 0 )
    pPlayer:SetNW2Int( "PRP.Heist.Loot", 0 )

    pPlayer:GetCharacter():GiveMoney( iLoot )
    pPlayer:Notify( "You have successfully robbed the bank for " .. ix.currency.Get( iLoot ) .. "." )

    PRP.Heist.PlayersWithLoot[pPlayer:SteamID()] = nil
end

hook.Add( "InitializedPlugins", "PRP.Heist.LootTimer", function()
    if timer.Exists( "PRP.Heist.LootTimer" ) then
        timer.Remove( "PRP.Heist.LootTimer" )
    end

    local oBank = PRP.Heist.Get( "bank" )

    timer.Create( "PRP.Heist.LootTimer", 1, 0, function()
        -- Print("LootTimer")
        for _, pPlayer in pairs( PRP.Heist.PlayersWithLoot ) do
            Print( "Player" )
            if not IsValid( pPlayer ) then
                --@TODO Some logic for removing them if they disconnected/died etc.
                Print( "Invalid player" )
                continue
            end

            if pPlayer:GetPos():DistToSqr( oBank:GetPos() ) < ix.config.Get( "heistLootDistance", 15000000 ) then
                -- If they are close to the bank, we restart the timer.
                Print( "Close to bank: " .. pPlayer:Name() )
                if pPlayer:GetLocalVar( "PRP.Heist.Safe" ) then
                    Print( "Restarting timer for " .. pPlayer:Name() )
                    pPlayer:SetLocalVar( "PRP.Heist.Safe", false )

                    timer.Remove( "PRP.Heist.LootTimer." .. pPlayer:SteamID64() )
                end
            else
                -- If they are far away, we start the timer or continue it.
                Print( "Far from bank: " .. pPlayer:Name() )
                if not pPlayer:GetLocalVar( "PRP.Heist.Safe" ) then
                    Print( "Starting timer for " .. pPlayer:Name() )
                    pPlayer:SetLocalVar( "PRP.Heist.Safe", CurTime() + ix.config.Get( "heistLootTimer", 15 ) * 60 )

                    timer.Create( "PRP.Heist.LootTimer." .. pPlayer:SteamID64(), ix.config.Get( "heistLootTimer", 15 ) * 60, 1, function()
                        fnLootTransfer( pPlayer )
                    end )
                end
            end
        end
    end )
end )