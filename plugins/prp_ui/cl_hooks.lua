PRP.UI.PLY_MENU = PRP.UI.PLY_MENU or false

function PLUGIN:OnSpawnMenuOpen()
    if PRP.UI.PLY_MENU then return false end
end

function PLUGIN:ScoreboardShow()
    if PRP.UI.PLY_MENU then
        PRP.UI.PLY_MENU:Remove()
        PRP.UI.PLY_MENU = false
    else
        PRP.UI.PLY_MENU = vgui.Create( "PRP.Menu" )
    end

    return true
end

bIntroRun = bIntroRun or false
function PLUGIN:OnCharacterMenuCreated( panel )
    if bIntroRun then return end

    bIntroRun = true

    panel:Remove()

    -- RunConsoleCommand( "prp_devpreview" )
    -- local dSplash = vgui.Create( "PRP.Splash" )

    -- panel:Hide()

    -- @TODO: Do better. (This overrides the splash screen's OnRemove function.)
    -- dSplash.OnRemove = function()
    --     if IsValid( panel ) then panel:Show() end
    -- end
end

function PLUGIN:InitPostEntity()
    -- OnCharacterMenuCreated is called before the game world entity exists.
    -- Because the main menu uses the game world entity for the intro sound,
    -- we're gonna open the main manu after InitPostEntity.
    PRP.UI.Intro = vgui.Create( "PRP.Intro" )
end

function PLUGIN:PlayerButtonDown( pPlayer, iButton )
    if (not IsFirstTimePredicted()) then return end

    if iButton == KEY_E then
        if (not ix.menu.IsOpen()) then
			local data = {}
			data.start = pPlayer:GetShootPos()
			data.endpos = data.start + pPlayer:GetAimVector() * 128
			data.filter = pPlayer

			local entity = util.TraceLine(data).Entity

			if (IsValid(entity) and isfunction(entity.GetEntityMenu)) then
				hook.Run("ShowEntityMenu", entity)
			end
		end

		timer.Remove("ixItemUse")

		pPlayer.ixInteractionTarget = nil
		pPlayer.ixInteractionStartTime = nil
    end
end

concommand.Add( "prp_splash", function()
    local dSplash = vgui.Create( "PRP.Splash" )
end )