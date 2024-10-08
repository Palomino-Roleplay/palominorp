AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName		= "Computer"
ENT.Author			= "sil"
ENT.Category        = "Palomino"
ENT.Purpose			= "Computer"
ENT.Instructions	= "Use with care. Always handle with gloves."

ENT.Spawnable		= true
ENT.AdminOnly		= true

function ENT:Initialize()
	-- Sets what model to use
	self:SetModel( self.Model or "models/props_lab/monitor01a.mdl" )

	-- Physics stuff
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	-- Init physics only on server, so it doesn't mess up physgun beam
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

        self:SetUseType( SIMPLE_USE )
	end

	-- Make prop to fall on spawn
	self:PhysWake()
end



if CLIENT then
    local function fnCalcView( pPlayer, vOrigin, aAngles, nFOV )
        if not IsValid( LocalPlayer().m_eComputer ) then return end

        local view = {}
        view.origin = LocalPlayer().m_eComputer:LocalToWorld( Vector( 64, 0, 8 ) )
        view.angles = LocalPlayer().m_eComputer:LocalToWorldAngles( Angle( 5.5, 180, 0 ) )
        view.fov = 30
        view.drawviewer = false

        return view
    end

    function ENT:Open()
        LocalPlayer().m_eComputer = self
        hook.Add( "CalcView", "PRP.Computer.CalcView", fnCalcView )

        -- ui3d2d.startDraw(pos, angles, scale, ignoredEntity)

        local vPos = self:LocalToWorld( Vector( 11.75, -9.8, 11.8 ) )
        local tToScreen = vPos:ToScreen()

        PRP_COMPUTER_MENU = vgui.Create( "DHTML" )
        PRP_COMPUTER_MENU:OpenURL( "http://loopback.gmod:8080")
        PRP_COMPUTER_MENU:SetSize( 392 * 2, 322 * 2 )
        PRP_COMPUTER_MENU:SetPos( tToScreen.x, tToScreen.y )
        PRP_COMPUTER_MENU:SetMouseInputEnabled( true )
        PRP_COMPUTER_MENU:SetKeyboardInputEnabled( true )
        PRP_COMPUTER_MENU.OnFinishLoadingDocument = function()
            PRP_COMPUTER_MENU:RunJavascript( "setGlobalAuthToken('" .. PRP.API.Token .. "');")
        end
        gui.EnableScreenClicker( true )
    end

    function ENT:Draw()
        self:DrawModel()
        local vStartPos = self:LocalToWorld( Vector( 11.75, -9.8, 11.8 ) )
        local vEndPos = vStartPos - self:GetAngles():Right() * 392 * 2 * 0.025
        vEndPos = vEndPos - self:GetAngles():Up() * 322 * 2 * 0.025
        vEndPos = vEndPos + self:GetAngles():Forward() * 1

        local aAng = self:LocalToWorldAngles( Angle( 0, 90, 85.5 ) )
        local iScale = 0.025
        -- ui3d2d.startDraw( vStartPos, aAng, iScale, self )
        --     draw.RoundedBox( 0, 0, 0, 392 * 2, 322 * 2, Color( 0, 255, 0, 255 ) )
        --     draw.RoundedBox( 0, 0, 0, 10, 10, Color( 255, 0, 0, 255 ) )

        --     -- draw.RoundedBox( 0, 392 * 2 - 10, 322 * 2 - 10, 10, 10, Color( 255, 0, 0, 255 ) )    
        -- ui3d2d.endDraw()

        -- ui3d2d.startDraw( vEndPos, aAng, iScale, self )
        --     draw.RoundedBox( 0, 0, 0, 1000, 10, Color( 255, 0, 255, 255 ) )
        -- ui3d2d.endDraw()

        if IsValid( PRP_COMPUTER_MENU ) then
            if LocalPlayer().m_eComputer != self then
                PRP_COMPUTER_MENU:SetPos( 0, 0 )
                ui3d2d.drawVgui( PRP_COMPUTER_MENU, vStartPos, aAng, iScale, self )
            else
                local tStartToScreen = vStartPos:ToScreen()
                PRP_COMPUTER_MENU:SetPos( tStartToScreen.x, tStartToScreen.y )

                local tEndToScreen = vEndPos:ToScreen()
                PRP_COMPUTER_MENU:SetSize( tEndToScreen.x - tStartToScreen.x, tEndToScreen.y - tStartToScreen.y)
            end
        end
    end

    function ENT:Close()
        hook.Remove( "CalcView", "PRP.Computer.CalcView" )
        LocalPlayer().m_eComputer = nil
        PRP_COMPUTER_MENU:Remove()
        PRP_COMPUTER_MENU:SetMouseInputEnabled( false )
        PRP_COMPUTER_MENU:SetKeyboardInputEnabled( false )
        gui.EnableScreenClicker( false )

        PRP_COMPUTER_MENU:SetSize( 392 * 2, 322 * 2 )

        timer.Simple( 60, function()
            if IsValid( PRP_COMPUTER_MENU ) and LocalPlayer().m_eComputer != self then
                PRP_COMPUTER_MENU:Remove()
            end
        end )
    end

    function ENT:OnRemove()
        if LocalPlayer().m_eComputer == self then
            self:Close()
        end
    end

    -- @TODO: Holy mother of god.
    hook.Add( "Think", "PRP.Computer.Think", function()
        -- button cooldown
        if input.IsKeyDown( KEY_SPACE ) then
            LocalPlayer().m_iButtonCooldown = LocalPlayer().m_iButtonCooldown or 0
            if LocalPlayer().m_iButtonCooldown < CurTime() then
                LocalPlayer().m_iButtonCooldown = CurTime() + 0.5
            else
                return
            end

            if LocalPlayer().m_eComputer then
                LocalPlayer().m_eComputer:Close()
            else
                local eComputer = LocalPlayer():GetEyeTrace().Entity
                if IsValid( eComputer ) and eComputer:GetClass() == "prp_computer" then
                    // distance check
                    if LocalPlayer():GetPos():DistToSqr( eComputer:GetPos() ) < 10000 then
                        eComputer:Open()
                    end
                end
            end
        end
    end )
end