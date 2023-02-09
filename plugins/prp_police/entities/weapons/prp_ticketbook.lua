SWEP.PrintName              = "Ticket Book"
SWEP.Author                 = "sil"
SWEP.Instructions           = "Left click to issue a ticket."
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

SWEP.ViewModel			    = Model( "models/realistic_police/finebook/c_notebook.mdl" )
SWEP.WorldModel			    = Model( "models/realistic_police/finebook/w_notebook.mdl" )
SWEP.ViewModelFOV           = 75
SWEP.UseHands               = true

SWEP.DrawAmmo               = false

function SWEP:Deploy()
    -- if not IsFirstTimePredicted() then return end

    local pPlayer = self:GetOwner()

    self:SendWeaponAnim( ACT_VM_DRAW )
    self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )

    timer.Simple( self:SequenceDuration(), function()
        if not IsValid( pPlayer ) then return end
        if not IsValid( self ) then return end
        if not pPlayer:Alive() then return end
        if pPlayer:GetActiveWeapon() ~= self then return end

        self:SendWeaponAnim( ACT_VM_IDLE )
    end )
end

function SWEP:Holster()
    -- if not IsFirstTimePredicted() then return end
    -- if CLIENT then self.CloseMenu() end

    return true
end

function SWEP:OnRemove()
    if not IsFirstTimePredicted() then return end
    if CLIENT then self.CloseMenu() end

    return true
end

if CLIENT then
    local dTicketPanel = false

    function SWEP:PrimaryAttack()
        if not IsFirstTimePredicted() then return end
        local pTarget = LocalPlayer():GetEyeTrace().Entity

        self:OpenMenu( pTarget )

        -- local pPlayer = self:GetOwner()

        -- self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        -- self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )

        -- print("test3")
    end

    function SWEP:SecondaryAttack()
        if not IsFirstTimePredicted() then return end
        self:CloseMenu()
    end

    function SWEP:OpenMenu( pTarget )
        if dTicketPanel then return end
        dTicketPanel = vgui.Create( "PRP.Police.TicketMenu" )
        dTicketPanel:SetTarget( pTarget )
    end

    function SWEP:CloseMenu()
        if dTicketPanel then dTicketPanel:Remove() end
        dTicketPanel = nil
    end
elseif SERVER then
    function SWEP:PrimaryAttack()
        if not IsFirstTimePredicted() then return end

        local pPlayer = self:GetOwner()

        -- @TODO: Maybe send only when the ticket is issued?
        self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
        self:SetNextPrimaryFire( CurTime() + self:SequenceDuration() )
    end

    function SWEP:SecondaryAttack()
        if not IsFirstTimePredicted() then return end
    end
end

function SWEP:Reload()
    return
end