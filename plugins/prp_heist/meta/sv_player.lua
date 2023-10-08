local PLAYER = FindMetaTable("Player")

PRP.Heist = PRP.Heist or {}
PRP.Heist.PlayersWithLoot = PRP.Heist.PlayersWithLoot or {}

function PLAYER:AddLoot( iAmount, sHeistID )
    local iMoney = self:GetNW2Int( "PRP.Heist.Loot", 0 )
    self:SetNW2Int( "PRP.Heist.Loot", iMoney + iAmount )

    if not PRP.Heist.PlayersWithLoot[self:SteamID()] then
        PRP.Heist.PlayersWithLoot[self:SteamID()] = self
    end
end