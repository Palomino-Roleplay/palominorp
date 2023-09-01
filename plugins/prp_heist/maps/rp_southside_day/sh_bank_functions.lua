PRP.Heist = PRP.Heist or {}
PRP.Heist.Southside = PRP.Heist.Southside or {}

local iLasersID = 3194
function PRP.Heist.Southside.ToggleBankLasers()
    local eEntity = ents.GetMapCreatedEntity( iLasersID )
    eEntity:Fire("use")
end

function PRP.Heist.Southside.SetBankLasers( bEnabled )
    local eEntity = ents.GetMapCreatedEntity( iLasersID )
    eEntity:Fire( bEnabled and "pressin" or "pressout" )
end


local iSecurityGatesID = 3141
function PRP.Heist.Southside.ToggleSecurityGates()
    local eEntity = ents.GetMapCreatedEntity( iSecurityGatesID )
    eEntity:Fire("toggle")
end

function PRP.Heist.Southside.SetSecurityGates( bEnabled )
    local eEntity = ents.GetMapCreatedEntity( iSecurityGatesID )
    eEntity:Fire(bEnabled and "open" or "close")
end


local iAlarmButtonID = 5097
function PRP.Heist.Southside.ToggleAlarm()
    local eEntity = ents.GetMapCreatedEntity( iAlarmButtonID )
    eEntity:Fire("use")
end