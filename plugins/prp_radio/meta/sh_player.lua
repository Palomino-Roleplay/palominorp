local PLY = FindMetaTable( "Player" )

function PLY:HasRadioFaction()
    return self:GetCharacter() and ix.faction.Get( self:GetCharacter():GetFaction() ).hasRadio
end

function PLY:HasRadio()
    return self:HasRadioFaction() or self:GetCharacter():GetInventory():HasItem( "handheld_radio" )
end

function PLY:GetRadioChannel()
    if self:HasRadioFaction() then
        return ix.faction.Get( self:GetCharacter():GetFaction() ).defaultRadioChannel
    end

    -- @TODO: (HIGH PRIORITY) Use net vars and player metatable instead.
    return self:GetNetVar( "radioChannel", "100.0" )
end

-- Radio channels are a string. Civilian stations are 100.00-199.99. Government ones are titled "Police" and etc.
function PLY:HasRadioChannelAccess( sChannel )
    if not self:HasRadio() then return false end

    if string.match( sChannel, "^%d%d%d%.%d%d$" ) and #sChannel == 6 then
        return tonumber( sChannel ) >= 100 and tonumber( sChannel ) <= 199.99
    end

    if self:HasRadioFaction() then
        return ix.faction.Get( self:GetCharacter():GetFaction() ).radioChannels[sChannel] or ix.class.Get( self:GetCharacter():GetClass() ).radioChannels[sChannel]
    end
end

-- Returns the special radios the character has access to as a member of a faction/class.
function PLY:GetSpecialRadios()
    -- @TODO: Yikes
    return table.Merge(
        table.Copy( table.GetKeys(
            ix.faction.Get( self:GetCharacter():GetFaction() ).specialRadios ) or {}
        ),
        table.Copy( table.GetKeys(
            ix.class.Get( self:GetCharacter():GetClass() ).specialRadios ) or {}
        )
    )
end

function PLY:OnSameChannel( pPlayer )
    return self:GetRadioChannel() == pPlayer:GetRadioChannel()
end