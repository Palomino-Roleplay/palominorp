local PLUGIN = PLUGIN

function PLUGIN:CanPlayerUseVendor( pPlayer )
    print("testo")
    -- @TODO: Add a check to see if the player is holding a weapon
    -- if pPlayer:GetActiveWeapon():GetClass() == "weapon_pistol" then
    --     print("test")
    --     return false
    -- end
end

-- @TODO: Move to a meta file
local ENT_VENDOR = scripted_ents.GetStored("ix_vendor").t
local fnOldUse = ENT_VENDOR.Use

function ENT_VENDOR:Use( pPlayer )
    -- @TODO: Restrict to only some vendors
    print("huh???? why????")

    -- if self._isBeingRobbed then return false end

    if self._lastRobbery and self._lastRobbery + ix.config.Get("NPCRobberyAlarmTime", 30 ) > CurTime() then
        pPlayer:Notify("The vendor seems to be shaken up from something.")
        return false
    end

    if pPlayer:GetActiveWeapon():GetClass() == "weapon_pistol" then
        self:StartRobbery( pPlayer )
        self._isBeingRobbed = true

        return false
    end

    fnOldUse(self, pPlayer)
end

function ENT_VENDOR:StartRobbery( pPlayer )
    pPlayer:SetAction("Robbing", ix.config.Get( "NPCRobberyHoldTime", 30 ))
    pPlayer:DoStaredAction(
        self,
        function()
            self:OnRobberySuccess( pPlayer )
        end,
        ix.config.Get( "NPCRobberyHoldTime", 30 ),
        function()
            self:OnRobberyFail( pPlayer )
        end,
        500
    )

    if math.Rand( 0, 1 ) < ix.config.Get( "NPCRobberyScreamChance", 0.3 ) then
        -- @TODO: Male and female sounds
        self:EmitSound( "ambient/voices/f_scream1.wav" )
    end
end

function ENT_VENDOR:OnRobberyOver( pPlayer )
    self._lastRobbery = CurTime()

    -- @TODO: Do better animations
    -- local iGesture = self:AddGesture( ACT_COVER_LOW )
    -- timer.Simple( ix.config.Get( "NPCRobberyAlarmTime", 30 ), function()
    --     if not IsValid( self ) then return end
    --     self:RemoveGesture( iGesture )
    --     self:ResetSequence( 4 )
    -- end )
end

function ENT_VENDOR:OnRobberySuccess( pPlayer )
    pPlayer:SetAction()
    self._isBeingRobbed = false

    self:OnRobberyOver()

    local iPayout = ix.config.Get( "NPCRobberyPayout", 500 )
    iPayout = iPayout + math.random( -iPayout * 0.1, iPayout * 0.1 )

    if math.Rand( 0, 1 ) < ix.config.Get( "NPCRobberyPoliceChance", 0 ) then
        pPlayer:Notify( "You've robbed " .. ix.currency.Get( iPayout ) .. " from the vendor, but the automatic alarm was triggered!" )
        self:CallPolice( pPlayer )
    else
        pPlayer:Notify( "You successfully robbed " .. ix.currency.Get( iPayout ) .. " from the vendor!" )
    end

    -- @TODO: Customize loot
    pPlayer:GetCharacter():GiveMoney( iPayout )
    -- @TODO: NPC and player cooldowns
end

function ENT_VENDOR:OnRobberyFail( pPlayer )
    pPlayer:SetAction()
    pPlayer:Notify("You looked away from the vendor and they triggered the alarm!")
    self._isBeingRobbed = false

    self:CallPolice( pPlayer )
    self:OnRobberyOver( pPlayer )
end

function ENT_VENDOR:CallPolice( pPlayer )
    local iAlarmTime = ix.config.Get("NPCRobberyAlarmTime", 5)
    local iAlarmSound = self:StartLoopingSound( "ambient/alarms/alarm1.wav" )
    timer.Simple( iAlarmTime, function()
        self:StopLoopingSound( iAlarmSound )
    end )

    -- pPlayer:Notify( "The alarm has been tripped!" )
    PRP.Police.AddCall( self:GetPos(), "Robbery", "A store has just been robbed!" )
end

-- @TODO: Remove or do something with it
if ix.config.Get("DeveloperMode", false) then
    -- Command is blocked :(
    -- RunConsoleCommand("lua_reloadents")

    for k, v in pairs( ents.GetAll() ) do
        if v:GetClass() == "ix_vendor" then
            v.Use = ENT_VENDOR.Use
            v.StartRobbery = ENT_VENDOR.StartRobbery
            v.OnRobberySuccess = ENT_VENDOR.OnRobberySuccess
            v.OnRobberyFail = ENT_VENDOR.OnRobberyFail
            v.OnRobberyOver = ENT_VENDOR.OnRobberyOver
            v.CallPolice = ENT_VENDOR.CallPolice
        end
    end
end
