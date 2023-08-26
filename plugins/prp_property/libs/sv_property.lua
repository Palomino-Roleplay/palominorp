local PLUGIN = PLUGIN

PRP = PRP or {}
PRP.Property = PRP.Property or {}
PRP.Prop = PRP.Prop or {}

util.AddNetworkString( "PRP.Prop.Spawn" )

function PRP.Prop.Spawn( pPlayer, sCategoryID, sModel )
    -- @TODO: Hell no.
    local tCategoryPath = string.Explode( "/", sCategoryID )

    local tCategory = {}
    local tBaseCategory = {}
    for _, sCategory in ipairs( tCategoryPath ) do
        if sCategory == tCategoryPath[1] then
            tCategory = PLUGIN.config.props[sCategory]
            tBaseCategory = PLUGIN.config.props[sCategory]
            continue
        end

        tCategory = tCategory.subcategories[sCategory]
    end

    -- Print( tCategory )

    if not tCategory then return end
    if not tCategory.models[sModel] then return end

    local tModelConfig = tCategory.models[sModel]

    if not pPlayer:GetCharacter() then return end
    local cCharacter = pPlayer:GetCharacter()

    local tProperties = cCharacter:GetRentedProperties()

    -- @TODO: Spawn this manually.
    local eProp = DoPlayerEntitySpawn( pPlayer, "prop_physics", sModel, tModelConfig.skin or 0, tModelConfig.bodygroups or nil )

    -- @TODO: See PlayerSpawnProp to implement these checks before spawning.
    local bPropertyInside = false
    for _, oProperty in pairs( tProperties ) do
        if oProperty:Contains( pPlayer:GetPos() ) and oProperty:Contains( eProp:GetPos() ) then
            bPropertyInside = true
            break
        end
    end

    if not bPropertyInside then
        pPlayer:Notify( "You may not spawn props outside of your property." )
        eProp:Remove()
        return false
    end

    hook.Run( "PlayerSpawnedProp", pPlayer, sModel, eProp )

    if tBaseCategory.OnSpawn then
        tBaseCategory.OnSpawn( eProp, pPlayer, sModel, tModelConfig )
    end

    if tBaseCategory.PhysgunDrop then
        eProp.PhysgunDrop = tBaseCategory.PhysgunDrop
    end

    eProp:SetNW2String( "PRP.Prop.Category", sCategoryID )
    eProp:SetNW2String( "PRP.Prop.Property", eProp:GetProperty():GetID() )
end

net.Receive( "PRP.Prop.Spawn", function( _, pPlayer )
    local sCategoryID = net.ReadString()
    local sModel = net.ReadString()

    PRP.Prop.Spawn( pPlayer, sCategoryID, sModel )
end )