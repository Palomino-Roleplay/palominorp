AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName		= "Payphone"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Testbench"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

if SERVER then
    util.AddNetworkString( "PRP.Payphone.Use" )
    util.AddNetworkString( "PRP.Payphone.Call" )
end

local vPhoneOnBoothOffset = Vector( 0, 0, 0 )

local vPhoneOnPlayerOffset = Vector( 0, 0, 0 )
local aPhoneOnPlayerOffset = Angle( 3.505, 70.489, -34.445 )

function ENT:Initialize()
    self:SetModel( "models/props_trainstation/payphone001a.mdl" )

    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    if SERVER then
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetUseType( SIMPLE_USE )
    end

    self:PhysWake()

    if SERVER then
        -- @TODO: Is there a better way to do this?
        self.ePhone = ents.Create( "prop_physics" )
        self.ePhone:SetModel( "models/props_trainstation/payphone_reciever001a.mdl" )

        -- No physics
        self.ePhone:SetMoveType( MOVETYPE_NONE )
        self.ePhone:SetSolid( SOLID_NONE )

        -- No collisions
        self.ePhone:SetCollisionGroup( COLLISION_GROUP_NONE )

        self.ePhone:SetParent( self )
        self.ePhone:SetPos( self:LocalToWorld( vPhoneOnBoothOffset ) )
        self.ePhone:SetAngles( self:GetAngles() )

        self.ePhone:Spawn()

        -- -- Fix this hack. I couldn't figure out how to make it work with Draw.
        -- self.ePhone.RenderGroup = RENDERGROUP_BOTH
        -- self.ePhone.Think = function( ePhone )
        --     Print("huh?")
        --     if not IsValid( self ) then return false end
        --     if IsValid( self:GetUser() ) then return false end

        --     Print("yay")

        --     ePhone:DrawModel()
        -- end
    end
end

function ENT:OnRemove()
    SafeRemoveEntity( self.ePhone )
end

function ENT:SetupDataTables()
    self:NetworkVar( "Entity", 0, "User" )
end

-- serverside
function ENT:AttachPhone( pPlayer )
    -- find the "eyes" tAttachment index
    local iAttachmentIndex = pPlayer:LookupAttachment("eyes")
    if iAttachmentIndex == 0 then return end

    -- get the tAttachment data
    local tAttachment = pPlayer:GetAttachment(iAttachmentIndex)
    if not tAttachment then return end

    -- set the position and angle with offsets
    local vNewPos = tAttachment.Pos + tAttachment.Ang:Forward() * vPhoneOnPlayerOffset.x + tAttachment.Ang:Right() * vPhoneOnPlayerOffset.y + tAttachment.Ang:Up() * vPhoneOnPlayerOffset.z
    local aNewAng = tAttachment.Ang + aPhoneOnPlayerOffset

    self.ePhone:SetParent( pPlayer, 1 )

    timer.Simple( 0, function()
        -- set entity position and angle
        self.ePhone:SetLocalPos( Vector( 0, 0, 0 ))
        self.ePhone:SetLocalAngles( Angles( 90, 90, 90 ))

        -- self.ePhone:SetMoveParent(pPlayer, "eyes")
        -- parent the entity to the player
    end )

    Print("hey?????")

    debugoverlay.EntityTextAtPosition( self.ePhone:GetPos(), 0, "Phone", 0, Color( 0, 255, 0 ), 1 )
end

hook.Add("HUDPaint", "PRP.Payphone.Draw", function()
    for _, ePhone in ipairs(ents.FindByClass("prp_payphone")) do
        if not IsValid( ePhone ) then continue end
        if not IsValid( ePhone.ePhone ) then continue end

        if not IsValid( ePhone:GetUser() ) then
            debugoverlay.EntityTextAtPosition( ePhone.ePhone, 0, "Phone", 0, Color( 0, 255, 0 ), 1 )
        end
    end
end)

-- serverside
function ENT:UnattachPhone()
    self.ePhone:SetParent( self )
    self.ePhone:SetPos( vPhoneOnBoothOffset )
    self.ePhone:SetAngles( self:GetAngles() )
end

function ENT:Use( pPlayer )
    local pUser = self:GetUser()

    if pUser == pPlayer then
        self:SetUser( nil )
        self:EmitSound( "buttons/button6.wav" )

        self:UnattachPhone()

        return
    end

    if IsValid( pUser ) then return end

    self:SetUser( pPlayer )
    self:EmitSound( "buttons/button9.wav" )

    self:AttachPhone( pPlayer )

    -- Print("ummm??")

    net.Start( "PRP.Payphone.Use" )
        net.WriteEntity( self )
    net.Send( pPlayer )
end

if SERVER then
    function ENT:Call( pPlayer, sNumber )
        if not IsValid( pPlayer ) then return end
        if not isstring( sNumber ) then return end
        if #sNumber < 1 then return end
        if self:GetUser() ~= pPlayer then return end

        self:EmitSound( "buttons/button14.wav" )

        net.Start( "PRP.Payphone.Call" )
            net.WriteString( sNumber )
        net.Send( pPlayer )
    end
end

if CLIENT then
    net.Receive( "PRP.Payphone.Use", function()
        Print("huh??")
        local pPhone = net.ReadEntity()

        if not IsValid( pPhone ) then return end

        -- local pMenu = vgui.Create( "PRP.Payphone.Menu" )
        -- pMenu:SetEntity( pPhone )
    end )
end

-- ix.menu.RegisterOption( ENT, "I'm Amazing", {
-- 	OnCanRun = function()
-- 		print("im a rock start")
-- 		return true
-- 	end,
-- 	OnRun = function( eEntity, pPlayer, sOption, tData )
-- 		print("OnRun")
-- 		if CLIENT then
-- 			surface.PlaySound( "common/bass.wav" )
-- 		else
-- 			eEntity:EmitSound( "common/center.wav" )
-- 		end
-- 	end,
-- } )