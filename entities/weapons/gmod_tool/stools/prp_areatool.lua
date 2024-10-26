TOOL.AddToMenu = true

TOOL.Category = "Palomino"
TOOL.Name = "#tool.prp_areatool.name"

TOOL.Information = {
	{ name = "left", stage = 0 },
    { name = "reload_1_use", stage = 0 },


	{ name = "left_1", stage = 1 },
	-- { name = "right_1", stage = 1 },
	{ name = "reload_1", stage = 1 },

    { name = "left_2", stage = 2 },
    { name = "right_2", stage = 2 },
	{ name = "reload_2", stage = 2 },
    { name = "left_2_use", stage = 2 },
    { name = "reload_2_use", stage = 2 },

    { name = "left_3", stage = 3 },
}

if CLIENT then
    language.Add( "tool.prp_areatool.name", "Area Tool" )
    language.Add( "tool.prp_areatool.desc", "Helper tool to create areas (parking spots, properties, etc.)" )
	language.Add( "tool.prp_areatool.left", "Start area" )
	language.Add( "tool.prp_areatool.left_1", "Complete current area" )
    -- language.Add( "tool.prp_areatool.right_1", "///" )
	language.Add( "tool.prp_areatool.reload_1_use", "Clear all areas" )

    language.Add( "tool.prp_areatool.left_2", "Move 1st point" )
    language.Add( "tool.prp_areatool.right_2", "Move 2nd point" )
	language.Add( "tool.prp_areatool.reload_2", "Clear current area" )
    language.Add( "tool.prp_areatool.left_2_use", "Save current area" )
    language.Add( "tool.prp_areatool.reload_2_use", "Clear all areas" )

    language.Add( "tool.prp_areatool.left_3", "Confirm" )
end

function TOOL:LeftClick( tTrace )
    if not IsFirstTimePredicted() then return end

    if self:GetStage() == 0 then
        self:SetStage( 1 )

        self.Area = {}
        self.Area[1] = tTrace.HitPos

        return true
    elseif self:GetStage() == 1 then
        self:SetStage( 2 )

        return true
    elseif self:GetStage() == 2 then
        if self:GetOwner():KeyDown( IN_USE ) then
            local vMin = Vector( math.min( self.Area[1].x, self.Area[2].x ), math.min( self.Area[1].y, self.Area[2].y ), math.min( self.Area[1].z, self.Area[2].z ) )
            local vMax = Vector( math.max( self.Area[1].x, self.Area[2].x ), math.max( self.Area[1].y, self.Area[2].y ), math.max( self.Area[1].z, self.Area[2].z ) )

            self.Area[1] = vMin
            self.Area[2] = vMax

            table.insert( self.SavedAreas, self.Area )
            self.Area = {}
            self:SetStage( 0 )

            if CLIENT then
                self:GetOwner():Notify( "The bound table has been printed to your console." )
                Print( self.SavedAreas )
            end

            return true
        end

        self.Move = 1
        self:SetStage( 3 )
        return true
    elseif self:GetStage() == 3 then
        self.Move = nil
        self:SetStage( 2 )
        return true
    end
end

function TOOL:RightClick( tTrace )
    if not IsFirstTimePredicted() then return end

    if self:GetStage() == 2 then
        self.Move = 2
        self:SetStage( 3 )
        return true
    elseif self:GetStage() == 3 then
        self.Move = nil
        self:SetStage( 2 )
        return true
    end
end

function TOOL:Reload( tTrace )
    if not IsFirstTimePredicted() then return end

    self.Area = {}
    self:SetStage( 0 )
    self.Move = nil

    if self:GetOwner():KeyDown( IN_USE ) then
        self.SavedAreas = {}
    end

    return true
end

function TOOL:Think()
    -- What fucking ever. TOOL:Deploy doesn't call on first deploy for some fucking reason.
    if not self.Area then
        self.SavedAreas = {}
        self.Area = {}
        self:SetStage( 0 )
        self.Move = nil
    end
end

function TOOL:Deploy()
    if not CLIENT then return end
    if not IsFirstTimePredicted() then return end

    self.Area = self.Area or {}
    self.SavedAreas = self.SavedAreas or {}
    -- We define the hook function inside TOOL:Deploy so we have access to the TOOL object (self)
    hook.Add( "PostDrawTranslucentRenderables", "PRP.Devtools.STools.AreaTool", function( bDrawingDepth, bDrawingSkybox, bDrawing3DSkybox )
        render.SetColorMaterial()

        for _, tSavedArea in pairs( self.SavedAreas ) do
            render.DrawBox( tSavedArea[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), tSavedArea[2] - tSavedArea[1], Color( 255, 255, 255, 10 ) )
            render.DrawWireframeBox( tSavedArea[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), tSavedArea[2] - tSavedArea[1], Color( 255, 255, 255, 255 ), true )

            cam.IgnoreZ( true )

            render.DrawBox( tSavedArea[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), tSavedArea[2] - tSavedArea[1], Color( 255, 255, 255, 3 ) )
            render.DrawWireframeBox( tSavedArea[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), tSavedArea[2] - tSavedArea[1], Color( 255, 255, 255, 30 ) )

            cam.IgnoreZ( false )
        end

        if not self.Area or not self.Area[1] then return end
        if self:GetStage() < 2 then
            local tTrace = util.TraceLine( {
                start = LocalPlayer():EyePos(),
                endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 500,
                filter = LocalPlayer()
            } )

            self.Area[2] = tTrace.HitPos
        end

        if self.Move then
            local tTrace = util.TraceLine( {
                start = LocalPlayer():EyePos(),
                endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 500,
                filter = LocalPlayer()
            } )

            if self.Move == 1 then
                self.Area[1] = tTrace.HitPos
                self.Area[2] = self.Area[2] + ( tTrace.HitPos - self.Area[1] )
            elseif self.Move == 2 then
                self.Area[2] = tTrace.HitPos
            end
        end

        -- Active Areas

        render.DrawBox( self.Area[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2] - self.Area[1], Color( 200, 200, 255, 10 ) )
        render.DrawWireframeBox( self.Area[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2] - self.Area[1], Color( 200, 200, 255, 255 ), true )

        cam.IgnoreZ( true )

        render.DrawBox( self.Area[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2] - self.Area[1], Color( 200, 200, 255, 3 ) )
        render.DrawWireframeBox( self.Area[1], Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2] - self.Area[1], Color( 200, 200, 255, 30 ) )

        cam.IgnoreZ( false )
    end )
end

function TOOL:Holster()
    if not CLIENT then return end
    hook.Remove( "PostDrawTranslucentRenderables", "PRP.Devtools.STools.AreaTool" )
end