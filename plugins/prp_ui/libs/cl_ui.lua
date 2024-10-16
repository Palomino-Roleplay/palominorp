PUI = PUI or {}

PUI.GREEN = Color( 43, 195, 140 )
PUI.BLUE = Color( 0, 165, 207 )
PUI.PURPLE = Color( 141, 106, 159 )
PUI.GRAY = Color( 57, 62, 65 )
PUI.GREY = PUI.GRAY
PUI.YELLOW = Color( 252, 236, 82 )
PUI.RED = Color( 255, 90, 90 )

PUI.WHITE = Color( 255, 255, 255 )
PUI.BLACK = Color( 0, 0, 0 )


PRP.m_tMaterials = PRP.m_tMaterials or {}
function PRP.Material( sMaterial, sParameters )
    local sHash = util.SHA256( sMaterial .. ( sParameters or "" ) )

    if not PRP.m_tMaterials[ sHash ] then
        PRP.m_tMaterials[ sHash ] = Material( sMaterial, sParameters )
    end

    return PRP.m_tMaterials[ sHash ]
end

function PUI.Box( iX, iY, iW, iH, cColor )
    surface.SetDrawColor( cColor )
    surface.DrawRect( iX, iY, iW, iH )
end

function PUI.StartOverlay()
    render.OverrideBlend(
        true,
        BLEND_DST_COLOR,
        BLEND_SRC_COLOR,
        BLENDFUNC_ADD
    )
end

function PUI.EndOverlay()
    render.OverrideBlend( false )
end

-- Interaction w/ Entities

function PUI.DrawInteractionEffects( eEntity )

end

-- hook.Remove( "PostDrawTranslucentRenderables", "PUI.DrawInteractionEffects" )

surface.CreateFont( "PRP.UI.Interaction.Option", {
    font = "Inter",
    size = 20,
    weight = 700,
    antialias = true
})

-- hook.Add( "PostDrawTranslucentRenderables", "PUI.DrawInteractionEffects", function()
-- 	render.SetStencilWriteMask( 0xFF )
-- 	render.SetStencilTestMask( 0xFF )
-- 	render.SetStencilReferenceValue( 0 )
-- 	render.SetStencilCompareFunction( STENCIL_ALWAYS )
-- 	render.SetStencilPassOperation( STENCIL_KEEP )
-- 	render.SetStencilFailOperation( STENCIL_KEEP )
-- 	render.SetStencilZFailOperation( STENCIL_KEEP )
-- 	render.ClearStencil()

-- 	-- Enable stencils
-- 	render.SetStencilEnable( true )
-- 	-- Force everything to fail
-- 	render.SetStencilCompareFunction( STENCIL_NEVER )
-- 	-- Save all the things we don't draw
-- 	render.SetStencilFailOperation( STENCIL_REPLACE )

-- 	-- Set the reference value to 00011100
-- 	render.SetStencilReferenceValue( 0x1C )
-- 	-- Set the write mask to 01010101
-- 	-- Any writes to the stencil buffer will be bitwise ANDed with this mask.
-- 	-- With our current reference value, the result will be 00010100.
-- 	render.SetStencilWriteMask( 0x55 )

-- 	-- Fail to draw our entities.
-- 	for _, ent in ipairs( ents.FindByClass( "player" ) ) do
-- 		ent:DrawModel()
-- 	end

-- 	-- Set the test mask to 11110011.
-- 	-- Any time a pixel is read out of the stencil buffer it will be bitwise ANDed with this mask.
-- 	render.SetStencilTestMask( 0xF3 )
-- 	-- Set the reference value to 00011100 & 01010101 & 11110011
-- 	render.SetStencilReferenceValue( 0x10 )
-- 	-- Pass if the masked buffer value matches the unmasked reference value
-- 	-- render.SetStencilCompareFunction( STENCIL_GREATER )

-- 	-- Draw our entities
-- 	-- render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )
--     local plyMat = Material( "prp/ui/temp/glow.png" )

--     for _, ent in ipairs( ents.FindByClass( "player" ) ) do
--         if ent == LocalPlayer() then continue end

--         render.SetStencilCompareFunction( STENCIL_GREATER )
--         local targetPos = ent:GetPos() + ent:OBBCenter() -- Center of the target player's bounding box
--         local dir = LocalPlayer():GetPos() - targetPos
--         local ang = dir:Angle()

--         -- Since we're using 3D2D, flip the pitch angle 90 degrees to orient correctly
--         ang:RotateAroundAxis(ang:Right(), -90)
--         ang:RotateAroundAxis(ang:Up(), 90)
--         -- ang.pitch = 0

--         local vPos = ent:GetPos() + ent:OBBCenter()
--         local iScaleFactor = 1 / ent:GetPos():Distance( LocalPlayer():GetPos() )

--         local iInitialWidth = 40000
--         local iInitialHeight = 75000

--         local tScreenPos = vPos:ToScreen()
--         local iX = tScreenPos.x - ( iInitialWidth / 2 * iScaleFactor )
--         local iY = tScreenPos.y - ( iInitialHeight / 2 * iScaleFactor )

--         local iWidth = iInitialWidth * iScaleFactor
--         local iHeight = iInitialHeight * iScaleFactor

--         local iSelectX = tScreenPos.x + ( 10000 * iScaleFactor )
--         local iSelectY = tScreenPos.y - ( 20000 * iScaleFactor )

--         cam.Start2D()
--             render.OverrideDepthEnable( true, false )

--             surface.SetMaterial(plyMat)
--             surface.SetDrawColor(255, 255, 255, 64)

--             Print( iX, ",\t", iY, ",\t", iWidth, ",\t", iHeight )

--             surface.DrawTexturedRect(iX, iY, iWidth, iHeight) -- Centered on the player's bounding box

--             -- surface.SetDrawColor( 255, 0, 0, 255 )
--             -- surface.DrawRect( iX, iY, iWidth, iHeight )

--             render.OverrideDepthEnable( false )
--         cam.End2D()

--         -- cam.Start3D2D(targetPos, ang, 0.1)
--         --     render.OverrideDepthEnable( true, false )

--         --     surface.SetMaterial(plyMat)
--         --     surface.SetDrawColor(255, 255, 255, 64)
            
--         --     -- The size of the texture in the 3D world. You might need to adjust these values
--         --     local w, h = 800, 1200
--         --     surface.DrawTexturedRect(-w/2, -h/2, w, h) -- Centered on the player's bounding box

--         --     render.OverrideDepthEnable( false )
--         -- cam.End3D2D()

--         render.SetStencilCompareFunction( STENCIL_GREATEREQUAL )

--         cam.Start2D()
--             surface.SetDrawColor( PUI.GREEN:Unpack() )
--             surface.DrawRect( iSelectX, iSelectY, 2, 40 )

--             PUI.StartOverlay()            
--                 surface.SetMaterial( Material( "prp/ui/temp/gradient_overlay2_left.png" ) )
--                 surface.SetDrawColor( 255, 255, 255, 255 )
--                 surface.DrawRect( iSelectX + 2, iSelectY, 200, 40 )
--             PUI.EndOverlay()

--             surface.SetMaterial( Material( "gui/gradient" ) )
--             surface.SetDrawColor( ColorAlpha( PUI.GREEN, 64 ):Unpack() )
--             surface.DrawTexturedRect( iSelectX + 2, iSelectY, 200, 40 )

--             surface.SetTextColor( 255, 255, 255, 255 )
--             surface.SetFont( "PRP.UI.Interaction.Option" )
--             surface.SetTextPos( iSelectX + 20, iSelectY + ( ( 40 - 20 ) / 2 ) )
--             surface.DrawText( "TRADE" )

--             -- 2

--             iSelectY = iSelectY + 40

--             surface.SetDrawColor( 255, 255, 255, 128 )
--             surface.DrawRect( iSelectX, iSelectY, 2, 40 )

--             surface.SetTextColor( 255, 255, 255, 128 )
--             surface.SetFont( "PRP.UI.Interaction.Option" )
--             surface.SetTextPos( iSelectX + 20, iSelectY + ( ( 40 - 20 ) / 2 ) )
--             surface.DrawText( "COPY STEAMID" )

--             -- 3

--             iSelectY = iSelectY + 40

--             surface.SetDrawColor( 255, 255, 255, 64 )
--             surface.DrawRect( iSelectX, iSelectY, 2, 40 )

--             surface.SetTextColor( 255, 255, 255, 64 )
--             surface.SetFont( "PRP.UI.Interaction.Option" )
--             surface.SetTextPos( iSelectX + 20, iSelectY + ( ( 40 - 20 ) / 2 ) )
--             surface.DrawText( "PAT DOWN" )
--         cam.End2D()
--     end


--     -- for _, ent in ipairs( ents.FindByClass( "prp_npc" ) ) do
--         -- PUI.StartOverlay()
--         --     -- @TODO: Something
--         --     surface.SetMaterial( Material( "effects/flashlight/soft" ) )
--         --     surface.SetDrawColor( 255, 255, 255, 255 )
--         --     surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
--         -- PUI.EndOverlay()
--     -- end

-- 	-- Let everything render normally again
-- 	render.SetStencilEnable( false )
-- end )