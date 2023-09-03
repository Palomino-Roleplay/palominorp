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


local iVaultButtonID = 5095
function PRP.Heist.Southside.ToggleVault()
    local eEntity = ents.GetMapCreatedEntity( iVaultButtonID )
    eEntity:Fire("use")
end


local iOuterDoor1 = 3112
local iOuterDoor2 = 3113
function PRP.Heist.Southside.ToggleOuterDoors()
    local eEntity1 = ents.GetMapCreatedEntity( iOuterDoor1 )
    local eEntity2 = ents.GetMapCreatedEntity( iOuterDoor2 )

    if not eEntity1 or not eEntity2 then return end

    eEntity1:Fire("toggle")
    eEntity2:Fire("toggle")
end