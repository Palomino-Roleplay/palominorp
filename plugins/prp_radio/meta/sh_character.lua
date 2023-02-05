local CHAR = ix.meta.character

function CHAR:HasRadioFaction()
    return ix.faction.Get( self:GetFaction() ).hasRadio
end

function CHAR:HasRadio()
    return self:HasRadioFaction() or self:GetInventory():HasItem( "handheld_radio" )
end

function CHAR:GetRadioChannel()
    if self:HasRadioFaction() then
        return self._defaultRadioChannel
    end

    -- @TODO: (HIGH PRIORITY) Use net vars and player metatable instead.
    return self:GetData( "radioChannel", "100.0" )
end

-- Radio channels are a string. Civilian stations are 100.00-199.99. Government ones are titled "Police" and etc.
function CHAR:HasRadioChannelAccess( sChannel )
    if not self:HasRadio() then return false end

    if string.match( sChannel, "^%d%d%d%.%d%d$" ) and #sChannel == 6 then
        return tonumber( sChannel ) >= 100 and tonumber( sChannel ) <= 199.99
    end

    if self:HasRadioFaction() then
        return ix.faction.Get( self:GetFaction() ).radioChannels[sChannel] or ix.class.Get( self:GetClass() ).radioChannels[sChannel]
    end
end

-- Returns the special radios the character has access to as a member of a faction/class.
function CHAR:GetSpecialRadios()
    -- @TODO: Yikes
    return table.Merge(
        table.Copy( table.GetKeys(
            ix.faction.Get( self:GetFaction() ).specialRadios ) or {}
        ),
        table.Copy( table.GetKeys(
            ix.class.Get( self:GetClass() ).specialRadios ) or {}
        )
    )
end

function CHAR:OnSameChannel( cCharacter )
    return self:GetRadioChannel() == cCharacter:GetRadioChannel()
end