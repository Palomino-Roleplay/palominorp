TOOL.AddToMenu = true

TOOL.Category = "palomino.life"
TOOL.Name = "#tool.prp_areatool.name"

TOOL.Information = {
	{ name = "left", stage = 0 },
	{ name = "left_1", stage = 1 },
	-- { name = "right_1", stage = 1 },
	{ name = "reload_1", stage = 1 },

    { name = "left_2", stage = 2 },
    { name = "right_2", stage = 2 },
	{ name = "reload_2", stage = 2 },

    { name = "left_3", stage = 3 },
}

if CLIENT then
    language.Add( "tool.prp_areatool.name", "Area Tool" )
    language.Add( "tool.prp_areatool.desc", "Helper tool to create areas (parking spots, properties, etc.)" )
	language.Add( "tool.prp_areatool.left", "Start area" )
	language.Add( "tool.prp_areatool.left_1", "Complete area" )
    -- language.Add( "tool.prp_areatool.right_1", "///" )
	language.Add( "tool.prp_areatool.reload_1", "Clear area" )

    language.Add( "tool.prp_areatool.left_2", "Move relative to 1st point" )
    language.Add( "tool.prp_areatool.right_2", "Move relative to 2nd point" )
	language.Add( "tool.prp_areatool.reload_2", "Clear area" )

    language.Add( "tool.prp_areatool.left_3", "Confirm" )
end

function TOOL:LeftClick( tTrace )
    if not IsFirstTimePredicted() then return end

    if self:GetStage() == 0 then
        self:SetStage( 1 )

        self.Area = {}
        self.Area[1] = {
            pos = tTrace.HitPos
        }

        return true
    elseif self:GetStage() == 1 then
        self:SetStage( 2 )

        Print( self.Area )
        return true
    elseif self:GetStage() == 2 then
        self.Move = 1
        self:SetStage( 3 )
        return true
    elseif self:GetStage() == 3 then
        Print( self.Area )
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
        Print( self.Area )
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

    return true
end

if CLIENT then
    function TOOL:Deploy()
        -- We define the hook function inside TOOL:Deploy so we have access to the TOOL object (self)
        hook.Add( "PostDrawTranslucentRenderables", "PRP.Devtools.STools.AreaTool", function( bDrawingDepth, bDrawingSkybox, bDrawing3DSkybox )
            render.SetColorMaterial()

            if not self.Area or not self.Area[1] then return end
            if self:GetStage() < 2 then
                local tTrace = util.TraceLine( {
                    start = LocalPlayer():EyePos(),
                    endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 500,
                    filter = LocalPlayer()
                } )

                self.Area[2] = {
                    pos = tTrace.HitPos
                }
            end

            if self.Move then
                local tTrace = util.TraceLine( {
                    start = LocalPlayer():EyePos(),
                    endpos = LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 500,
                    filter = LocalPlayer()
                } )

                if self.Move == 1 then
                    self.Area[1].pos = tTrace.HitPos
                    self.Area[2].pos = self.Area[2].pos + ( tTrace.HitPos - self.Area[1].pos )
                elseif self.Move == 2 then
                    self.Area[2].pos = tTrace.HitPos
                end
            end

            render.DrawBox( self.Area[1].pos, Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2].pos - self.Area[1].pos, Color( 255, 255, 255, 10 ) )
            render.DrawWireframeBox( self.Area[1].pos, Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2].pos - self.Area[1].pos, Color( 255, 255, 255, 255 ), true )

            cam.IgnoreZ( true )

            render.DrawBox( self.Area[1].pos, Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2].pos - self.Area[1].pos, Color( 255, 255, 255, 3 ) )
            render.DrawWireframeBox( self.Area[1].pos, Angle( 0, 0, 0 ), Vector( 0, 0, 0 ), self.Area[2].pos - self.Area[1].pos, Color( 255, 255, 255, 30 ) )

            cam.IgnoreZ( false )
        end )
    end

    function TOOL:Holster()
        hook.Remove( "PostDrawTranslucentRenderables", "PRP.Devtools.STools.AreaTool" )
    end
end