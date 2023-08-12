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

    -- RunConsoleCommand( "prp_devpreview" )
    local dSplash = vgui.Create( "PRP.Splash" )

    panel:Hide()

    -- @TODO: Do better. (This overrides the splash screen's OnRemove function.)
    dSplash.OnRemove = function()
        if IsValid( panel ) then panel:Show() end
    end
end

concommand.Add( "prp_splash", function()
    local dSplash = vgui.Create( "PRP.Splash" )
end )