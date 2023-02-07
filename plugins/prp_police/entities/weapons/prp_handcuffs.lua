SWEP.PrintName              = "Handcuffs"
SWEP.Author                 = "Kobralost & sil"
SWEP.Instructions           = "Primary Fire: handcuff.\nSecondary Fire: uncuff."
SWEP.Category               = "Palomino: Police"

SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.ViewModel              = Model("models/realistic_police/handcuffs/c_handcuffs.mdl")
SWEP.WorldModel             = Model("models/realistic_police/handcuffs/w_handcuffs.mdl")
SWEP.ViewModelFOV           = 80
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

-- @TODO: Figure out what the fuck is wrong with these animations

ix.menu.RegisterPlayerOption( "Drag", {
    OnCanRun = function( pVictim, pPlayer, sOption, tData )
        return pVictim:IsPlayer()
            and not pVictim:GetNetVar( "draggedBy", false )
            and pVictim:GetPos():DistToSqr( pPlayer:GetPos() ) <= 8000
            and pVictim:IsHandcuffed()
            -- and not IsValid( pPlayer:GetNetVar( "dragging", NULL ) )
    end,
    OnRun = function( pVictim, pPlayer, sOption, tData )
        Realistic_Police.Drag( pVictim, pPlayer )
    end
} )

ix.menu.RegisterPlayerOption( "Stop Dragging", {
    OnCanRun = function( pVictim, pPlayer, sOption, tData )
        return pVictim:GetNetVar( "draggedBy", false ) == pPlayer
    end,
    OnRun = function( pVictim, pPlayer, sOption, tData )
        Realistic_Police.Drag( pVictim, pPlayer )
    end
} )

function SWEP:Initialize()
    self:SetHoldType( "passive" )
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:EmitSound("rpthandcuffdeploy.mp3")
end

function SWEP:CanCuff( pVictim )
    local pOfficer = self:GetOwner()

    if pVictim:GetPos():DistToSqr( pOfficer:GetPos() ) > 8000 then return false, false end
    if not pOfficer:GetCharacter() then return false, false end
    if pVictim:GetClass() == "prop_ragdoll" and pVictim:GetNetVar( "player", NULL ) and pVictim:GetNetVar( "player", NULL ):GetNetVar( "tazed", false ) then
        if pVictim.ixIgnoreDelete then
            self:GetOwner():Notify( "A dead body doesn't need to be handcuffed." )
            return false, true
        end

        return true, true
    end
    if not pVictim:IsPlayer() then return false, false end
    if not pVictim:GetCharacter() then return false, false end

    return true, false
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    local pOfficer = self:GetOwner()
    local pVictim = pOfficer:GetEyeTrace().Entity

    self:SetNextPrimaryFire( CurTime() + 1 )

    local bCanCuff, bIsRagdoll = self:CanCuff( pVictim )

    if not bCanCuff then return end

    if bIsRagdoll then
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:EmitSound("rpthandcuffleftclick.mp3")

        if CLIENT then return end

        local pVictimPlayer = pVictim:GetNetVar( "player", NULL )
        if not IsValid( pVictimPlayer ) then return end

        if pVictimPlayer:IsHandcuffed() then
            self:GetOwner():Notify( "This body isn't handcuffed." )
            return
        end

        self:GetOwner():Notify( "You've hancuffed the body." )

        local cVictimCharacter = pVictimPlayer:GetCharacter()
        if not cVictimCharacter then return end

        -- pVictimPlayer:SetNetVar( "handcuffed", true )
        pVictimPlayer:Handcuff()

        pVictim:CallOnRemove( "handcuff", function()
            if not IsValid( pVictimPlayer ) then return end
            if not cVictimCharacter then return end
            if pVictimPlayer:GetCharacter() ~= cVictimCharacter then return end

            pVictimPlayer:Handcuff()
        end )

        return
    end

    if pVictim:IsHandcuffed() then return end

    if SERVER then
        -- @TODO: Fix the animation
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

        pVictim:Handcuff()
        -- @TODO: Check if other players can hear this
        self:EmitSound("rpthandcuffleftclick.mp3")
    end

    self:SetNextPrimaryFire( CurTime() + 3 )
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    local pOfficer = self:GetOwner()
    local pVictim = pOfficer:GetEyeTrace().Entity

    if not IsValid( pVictim ) then return end

    self:SetNextSecondaryFire( CurTime() + 0.5 )

    local bCanCuff, bIsRagdoll = self:CanCuff( pVictim )
    if not bCanCuff then return end

    if bIsRagdoll then
        if CLIENT then return end

        local pVictimPlayer = pVictim:GetNetVar( "player", NULL )

        if not IsValid( pVictimPlayer ) then return end

        if not pVictimPlayer:IsHandcuffed() then
            self:GetOwner():Notify( "This body isn't handcuffed." )
            return
        end

        -- pVictimPlayer:SetNetVar( "handcuffed", false )
        local cVictimCharacter = pVictimPlayer:GetCharacter()
        if not cVictimCharacter then return end

        pVictimPlayer:Uncuff()

        pVictim:RemoveCallOnRemove( "handcuff" )
        pVictim:CallOnRemove( "handcuff", function()
            if not IsValid( pVictimPlayer ) then return end
            if pVictimPlayer:GetCharacter() ~= cVictimCharacter then return end

            pVictimPlayer:Uncuff()
        end )

        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
        self:EmitSound("rpthandcuffleftclick.mp3")

        self:GetOwner():Notify( "You've unhancuffed the body." )

        return
    end

    if not pVictim:IsHandcuffed() then return end

    if SERVER then
        -- @TODO Animation?

        -- pVictim:SetNetVar( "handcuffed", false )
        pVictim:Uncuff()

        self:EmitSound("rpthandcuffleftclick.mp3")
    end

    self:SetNextSecondaryFire( CurTime() + 3 )

    -- @TODO: Consider different sound for uncuffing
end