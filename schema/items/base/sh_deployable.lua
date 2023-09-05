
ITEM.name = "Deployable Base"
ITEM.model = "models/hunter/blocks/cube075x075x075.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "A deployable item."
ITEM.category = "Deployable"
ITEM.entClass = "prp_deployable_base"

function ITEM:Spawn(position, angles)
    -- Check if the item has been created before.
    if (ix.item.instances[self.id]) then
        local client

        -- Spawn the actual item entity.
        local entity = ents.Create(self.entClass or "ix_item")
        entity:Spawn()
        entity:SetAngles( angles or Angle(0, 0, 0) )
        -- entity:SetItem( self.id )

        -- If the first argument is a player, then we will find a position to drop
        -- the item based off their aim.
        if type(position) == "Player" then
            client = position
            position = position:GetItemDropPos(entity)
        end

        entity:SetPos(position)

        if IsValid(client) then
            entity.ixSteamID = client:SteamID()
            entity.ixCharID = client:GetCharacter():GetID()
            entity:SetNetVar("owner", entity.ixCharID)
        end

        if self.OnSpawn then
            self:OnSpawn(entity, client)
        end

        hook.Run("OnItemDeployed", entity)
        return entity
    end
end

function ITEM:OnSpawn()
end

function ITEM:OnRegistered()
    local tEntTable = scripted_ents.GetStored( self.entClass )
    if not tEntTable then return end

    ix.menu.RegisterOption( tEntTable.t, "Pick Up", {
        OnRun = function( eEntity, pPlayer, sOption, tData )
            local bSuccess, error = pPlayer:GetCharacter():GetInventory():Add( self.uniqueID, 1 )

            if bSuccess then
                pPlayer:EmitSound( "npc/zombie/foot_slide" .. math.random( 1, 3 ) .. ".wav", 75, math.random( 90, 120 ), 1 )
                eEntity:Remove()
            else
                pPlayer:NotifyLocalized( "@" .. tostring(error) )
            end
        end,
        OnCanRun = function( eEntity, pPlayer, sOption, tData )
            return true
        end
    })
end