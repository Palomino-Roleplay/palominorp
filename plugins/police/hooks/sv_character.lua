local PLUGIN = PLUGIN

function PLUGIN:CharacterPreSave( cChar )
    cChar:SetData( "arrest_time", cChar:GetArrestTimeRemaining() )
end