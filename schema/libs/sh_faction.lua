ix.faction = ix.faction or {}
ix.faction.teams = ix.faction.teams or {}
ix.faction.indices = ix.faction.indices or {}

function Schema:InitializedPlugins()
    -- @TODO: ICKY

    -- @TODO: Have inheritance for bodygroups as well as models.
    for _, oFaction in pairs( ix.faction.indices ) do
        function oFaction:GetModel( pPlayer )
            if self.modelBase then
                return string.format( self.modelBase, pPlayer:GetModelBase() )
            end

            if self.model then return self.model end

            if self.models then return table.Random( self.models ) end

            return "models/player/kleiner.mdl"
        end
    end

    for _, oClass in pairs( ix.class.list ) do
        function oClass:GetModel( pPlayer )
            if self.modelBase then
                return string.format( self.modelBase, pPlayer:GetModelBase() )
            end

            if self.model then return self.model end

            if self.models then return table.Random( self.models ) end

            return ix.faction.indices[ self.faction ]:GetModel( pPlayer )
        end
    end
end

-- @TODO: Move
local ENT = FindMetaTable( "Entity" )

function ENT:GetBodyGroupsString()
    local sBodyGroups = ""

    for iIndex, tBodyGroup in ipairs( self:GetBodyGroups() ) do
        local iBodyGroupValue = self:GetBodygroup( tBodyGroup.id )
        local sBodyGroup = iBodyGroupValue < 10 and iBodyGroupValue or string.char( iBodyGroupValue - 96 )
        sBodyGroups = sBodyGroups .. sBodyGroup
    end

    return sBodyGroups
end