PRP.Color = PRP.Color or {}

PRP.Color.GREEN = Color( 43, 195, 140 )
PRP.Color.BLUE = Color( 0, 165, 207 )
PRP.Color.PURPLE = Color( 141, 106, 159 )
PRP.Color.GRAY = Color( 57, 62, 65 )
PRP.Color.GREY = PRP.Color.GRAY
PRP.Color.YELLOW = Color( 252, 236, 82 )
PRP.Color.RED = Color( 233, 79, 55 )

PRP.Color.WHITE = Color( 255, 255, 255 )
PRP.Color.BLACK = Color( 0, 0, 0 )

PRP.Color.PRIMARY = PRP.Color.GREEN
PRP.Color.SECONDARY = PRP.Color.BLUE
PRP.Color.TERTIARY = PRP.Color.PURPLE



PRP.m_tMaterials = PRP.m_tMaterials or {}
function PRP.Material( sMaterial, sParameters )
    local sHash = util.SHA256( sMaterial .. ( sParameters or "" ) )

    if not PRP.m_tMaterials[ sHash ] then
        PRP.m_tMaterials[ sHash ] = Material( sMaterial, sParameters )
    end

    return PRP.m_tMaterials[ sHash ]
end


-- Maybe this instead?

PUI = PUI or {}

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

hook.Add( "PostDrawTranslucentRenderables", "PUI.DrawInteractionEffects", function()
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	-- Enable stencils
	render.SetStencilEnable( true )
	-- Force everything to fail
	render.SetStencilCompareFunction( STENCIL_NEVER )
	-- Save all the things we don't draw
	render.SetStencilFailOperation( STENCIL_REPLACE )

	-- Set the reference value to 00011100
	render.SetStencilReferenceValue( 0x1C )
	-- Set the write mask to 01010101
	-- Any writes to the stencil buffer will be bitwise ANDed with this mask.
	-- With our current reference value, the result will be 00010100.
	render.SetStencilWriteMask( 0x55 )

	-- Fail to draw our entities.
	for _, ent in ipairs( ents.FindByClass( "player" ) ) do
		ent:DrawModel()
	end

	-- Set the test mask to 11110011.
	-- Any time a pixel is read out of the stencil buffer it will be bitwise ANDed with this mask.
	render.SetStencilTestMask( 0xF3 )
	-- Set the reference value to 00011100 & 01010101 & 11110011
	render.SetStencilReferenceValue( 0x10 )
	-- Pass if the masked buffer value matches the unmasked reference value
	render.SetStencilCompareFunction( STENCIL_GREATER )

	-- Draw our entities
	-- render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )
    local plyMat = Material( "prp/ui/temp/glow.png" )
    
    for _, ent in ipairs( ents.FindByClass( "player" ) ) do
        local targetPos = ent:GetPos() + ent:OBBCenter() -- Center of the target player's bounding box
        local dir = LocalPlayer():GetPos() - targetPos
        local ang = dir:Angle()

        -- Since we're using 3D2D, flip the pitch angle 90 degrees to orient correctly
        ang:RotateAroundAxis(ang:Right(), -90)
        ang:RotateAroundAxis(ang:Up(), 90)
        -- ang.pitch = 0

        cam.Start3D2D(targetPos, ang, 0.1)
            render.OverrideDepthEnable( true, false )

            surface.SetMaterial(plyMat)
            surface.SetDrawColor(255, 255, 255, 64)
            
            -- The size of the texture in the 3D world. You might need to adjust these values
            local w, h = 800, 1200
            surface.DrawTexturedRect(-w/2, -h/2, w, h) -- Centered on the player's bounding box

            render.OverrideDepthEnable( false )
        cam.End3D2D()
    end

    render.SetStencilCompareFunction( STENCIL_EQUAL )

    for _, ent in ipairs( ents.FindByClass( "player" ) ) do
        -- PUI.StartOverlay()
        --     -- @TODO: Something
        --     surface.SetMaterial( Material( "effects/flashlight/soft" ) )
        --     surface.SetDrawColor( 255, 255, 255, 255 )
        --     surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
        -- PUI.EndOverlay()
    end

	-- Let everything render normally again
	render.SetStencilEnable( false )
end )