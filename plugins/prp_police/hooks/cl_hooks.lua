local PLUGIN = PLUGIN

function PLUGIN:CanPlayerViewInventory()
    if LocalPlayer():GetCharacter():IsArrested() then return false end
end

function PLUGIN:GetCharacterName( pSpeaker, sChatType )
    if LocalPlayer():GetCharacter():IsPolice() and ( sChatType == "911" ) then
        PRP.Police.AddPlayerCall( pSpeaker )

        return pSpeaker:GetCharacter():GetName()
    end
end

local function GetPoliceComputerComponent( eVehicle )
    if not IsValid( eVehicle ) then return end
    local ePhotonController = eVehicle:GetPhotonController()
    if not ePhotonController then return end

    for _, eEntity in pairs( ePhotonController.Components ) do
        if eEntity.Title == "Palomino Police Computer" then
            return eEntity
        end
    end
end

LALALALALALA = Vector( -23, 0, 9.2 )
BIBIBIBIBIBI = Angle( 5, 0, 0 )
DIDIDIDIDID = Vector( 0, 4.7, 10.8 )
POPOPO = 1100
PIPIPI = 850
local iAnimationTime = 0.7
local tScreenPos = false
local function fnCalcView( pPlayer, vOrigin, aAngles, nFOV )
    -- Print("fnCalcView")

    if not LocalPlayer():InVehicle() then return end
    if not IsValid( LocalPlayer().m_eComputer ) then return end

    -- Print("CALC VIEWING")

    if not tScreenPos then
        tScreenPos = LocalPlayer().m_eComputer:LocalToWorld( DIDIDIDIDID ):ToScreen()
    end

    local iAnimPerc = math.Clamp( math.ease.OutExpo( ( CurTime() - LocalPlayer().m_iComputerOpen ) / iAnimationTime ), 0, 1 )

    local tView = {}
    tView.origin = LerpVector( iAnimPerc, vOrigin, LocalPlayer().m_eComputer:LocalToWorld( LALALALALALA ) )
    tView.angles = LerpAngle( iAnimPerc, aAngles, LocalPlayer().m_eComputer:LocalToWorldAngles( BIBIBIBIBIBI ) )
    tView.fov = Lerp( iAnimPerc, nFOV, 30 )
    tView.drawviewer = false

    return tView
end
hook.Add( "CalcView", "_PRP.Computer.CalcView", fnCalcView )

function PLUGIN:EntityNetworkedVarChanged( eEntity, sKey, sOldValue, sNewValue )
    if not LocalPlayer():InVehicle() then return end
    if LocalPlayer():GetVehicle() == eEntity and sKey == "Photon2:CS:Palomino.PoliceComputer" then
        local eComputer = GetPoliceComputerComponent( LocalPlayer():GetVehicle() )
        if sNewValue == "ON" then
            if PRP_COMPUTER_MENU then
                PRP_COMPUTER_MENU:Remove()
                gui.EnableScreenClicker( false )
            end

            -- LocalPlayer():EmitSound( "Controller" )
            Print("OPENING COMPUTER")
            LocalPlayer().m_eComputer = eComputer
            LocalPlayer().m_iComputerOpen = CurTime()
            -- hook.Add( "CalcView", "PRP.Computer.CalcView", fnCalcView )

            -- local vPos = eComputer:LocalToWorld( DIDIDIDIDID )
            -- local tToScreen = vPos:ToScreen()

            -- Print(tToScreen)

            timer.Simple( iAnimationTime * 0.7, function()
                Print( tScreenPos )

                if PRP_COMPUTER_MENU and IsValid( PRP_COMPUTER_MENU ) then return end

                PRP_COMPUTER_MENU = vgui.Create( "DHTML" )
                PRP_COMPUTER_MENU:OpenURL( "https://pal-os.palominorp.com")
                PRP_COMPUTER_MENU:SetSize( 1130 * PRP.UI.ScaleFactor, 850 * PRP.UI.ScaleFactor )
                -- PRP_COMPUTER_MENU:SetPos( tScreenPos.x, tScreenPos.y )
                PRP_COMPUTER_MENU:Center()
                PRP_COMPUTER_MENU:SetMouseInputEnabled( true )
                PRP_COMPUTER_MENU:SetKeyboardInputEnabled( true )
                PRP_COMPUTER_MENU.OnFinishLoadingDocument = function()
                    PRP_COMPUTER_MENU:RunJavascript( "setGlobalAuthToken('" .. PRP.API.Token .. "');")
                end
                gui.EnableScreenClicker( true )

                PRP_COMPUTER_MENU.CloseButton = vgui.Create( "DButton", PRP_COMPUTER_MENU )
                PRP_COMPUTER_MENU.CloseButton:SetSize( 50, 50 )
                PRP_COMPUTER_MENU.CloseButton:SetPos( PRP_COMPUTER_MENU:GetWide() - 50, 0 )
                PRP_COMPUTER_MENU.CloseButton:SetText( "X" )
                PRP_COMPUTER_MENU.CloseButton:SetFont( "DermaLarge" )
                PRP_COMPUTER_MENU.CloseButton.DoClick = function( this )
                    this:GetParent():Remove()
                    LocalPlayer().m_eComputer = nil
                    gui.EnableScreenClicker( false )
                end
            end )
        else
            -- LocalPlayer():EmitSound( "Controller" )
            Print("CLOSING COMPUTER")
            LocalPlayer().m_eComputer = nil
            tScreenPos = nil
            -- hook.Remove( "CalcView", "PRP.Computer.CalcView" )

            if PRP_COMPUTER_MENU then
                PRP_COMPUTER_MENU:Remove()
                gui.EnableScreenClicker( false )
            end
        end
    end
end

-- @TODO: Move this shit

-- hook.Add( "CalcView", "PRP.Computer.CalcViewWWWW", function( pPlayer, vOrigin, aAngles, nFOV )
--     print("????")

--     if not IsValid( LocalPlayer().m_eComputer ) then return end

--     print("calcviewing")

--     local view = {}
--     view.origin = LocalPlayer().m_eComputer:LocalToWorld( LALALALALALA )
--     view.angles = LocalPlayer().m_eComputer:LocalToWorldAngles( BIBIBIBIBIBI )
--     view.fov = 30
--     view.drawviewer = false

--     return view
-- end )



-- concommand.Add( "prp_knight_shutup", function()
--     -- if LocalPlayer().m_eComputer then
--     --     LocalPlayer().m_eComputer = false
--     -- end

--     if PRP_COMPUTER_MENU then
--         PRP_COMPUTER_MENU:Remove()
--         gui.EnableScreenClicker( false )
--     end

--     if not LocalPlayer():InVehicle() then return end
--     local ePhotonController = LocalPlayer():GetVehicle():GetPhotonController()
--     if not ePhotonController then return end

--     print("suck my dick")

--     local eComputer = NULL
--     for _, eEntity in pairs(ePhotonController.Components) do
--         if eEntity.Title == "Palomino Police Computer" then
--             -- @TODO: Cache
--             eComputer = eEntity
--             break
--         end
--     end

--     if ( not eComputer ) or eComputer == NULL then return end

--     print("what the fucLK???")

--     LocalPlayer().m_eComputer = eComputer

--     hook.Add( "CalcView", "PRP.Computer.CalcView", fnCalcView )

--     -- ui3d2d.startDraw(pos, angles, scale, ignoredEntity)

--     -- local vPos = eComputer:LocalToWorld( Vector( 11.75, -9.8, 11.8 ) )
--     -- local tToScreen = vPos:ToScreen()

--     -- PRP_COMPUTER_MENU = vgui.Create( "DHTML" )
--     -- PRP_COMPUTER_MENU:OpenURL( "https://pal-os.palominorp.com")
--     -- PRP_COMPUTER_MENU:SetSize( 392 * 2, 322 * 2 )
--     -- PRP_COMPUTER_MENU:SetPos( tToScreen.x, tToScreen.y )
--     -- PRP_COMPUTER_MENU:SetMouseInputEnabled( true )
--     -- PRP_COMPUTER_MENU:SetKeyboardInputEnabled( true )
--     -- PRP_COMPUTER_MENU.OnFinishLoadingDocument = function()
--     --     PRP_COMPUTER_MENU:RunJavascript( "setGlobalAuthToken('" .. PRP.API.Token .. "');")
--     -- end
--     -- gui.EnableScreenClicker( true )
-- end )

-- concommand.Add("prp_silsucks", function()
--     -- ui3d2d.startDraw(pos, angles, scale, ignoredEntity)

--     if PRP_COMPUTER_MENU then
--         PRP_COMPUTER_MENU:Remove()
--     end

--     local vPos = LocalPlayer().m_eComputer:LocalToWorld( DIDIDIDIDID )
--     local tToScreen = vPos:ToScreen()

--     PRP_COMPUTER_MENU = vgui.Create( "DHTML" )
--     PRP_COMPUTER_MENU:OpenURL( "https://pal-os.palominorp.com")
--     PRP_COMPUTER_MENU:SetSize( POPOPO, PIPIPI )
--     PRP_COMPUTER_MENU:SetPos( tToScreen.x, tToScreen.y )
--     PRP_COMPUTER_MENU:SetMouseInputEnabled( true )
--     PRP_COMPUTER_MENU:SetKeyboardInputEnabled( true )
--     PRP_COMPUTER_MENU.OnFinishLoadingDocument = function()
--         PRP_COMPUTER_MENU:RunJavascript( "setGlobalAuthToken('" .. PRP.API.Token .. "');")
--     end
--     gui.EnableScreenClicker( true )
-- end)