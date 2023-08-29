
-- Defensive Props
local DefensiveProps = PRP.Prop.Category.New("defensive_props", "Defensive Props", "icon16/bomb.png" )

    local DefensiveProps_Small = DefensiveProps:NewChild("small", "Small")
    DefensiveProps_Small:AddModel( "models/mosi/fallout4/props/fortifications/gravelwall.mdl", {
        bodygroups = "010000000",
        snapPoints = {
            {
                selfOnly = true,
                point = Vector( 0, 40, 44 ),
                angleGrid = Angle( 360, 180, 360 ),
            },
            {
                selfOnly = true,
                point = Vector( 0, -42, 44 ),
                angleGrid = Angle( 360, 180, 360 ),
            },
        },
        bboxMult = Vector( 1.25, 1.75, 1 ),
    } )

    local DefensiveProps_Medium = DefensiveProps:NewChild("medium", "Medium")
    DefensiveProps_Medium:AddModel( "models/props_fortifications/sandbags_corner1.mdl" )
    DefensiveProps_Medium:AddModel( "models/props_fortifications/sandbags_corner1_tall.mdl" )
    DefensiveProps_Medium:AddModel( "models/props_fortifications/sandbags_line1.mdl" )
    DefensiveProps_Medium:AddModel( "models/props_fortifications/sandbags_line1_tall.mdl" )

    local DefensiveProps_Large = DefensiveProps:NewChild("large", "Large")
    DefensiveProps_Large:AddModel( "models/props_fortifications/sandbags_corner2.mdl" )
    DefensiveProps_Large:AddModel( "models/props_fortifications/sandbags_corner2_tall.mdl" )
    DefensiveProps_Large:AddModel( "models/props_fortifications/sandbags_line2.mdl" )
    DefensiveProps_Large:AddModel( "models/props_fortifications/sandbags_line2_tall.mdl" )

DefensiveProps:AddHook( "OnSpawn", function( eProp, pPlayer, sModel, tModelConfig )
    Print( "We do be runnning OnSpawn huh" )
    constraint.Keepupright( eProp, Angle( 0, 90, 0 ), 0, 9999999 )

    local oPhysics = eProp:GetPhysicsObject()
    if not oPhysics then return end

    oPhysics:EnableMotion( false )
end )

DefensiveProps:AddHook( "PhysgunDrop", function( eProp, pPlayer )
    if CLIENT then return end
    local oPhysics = eProp:GetPhysicsObject()

    if not oPhysics then return end

    oPhysics:EnableMotion( false )

    if oPhysics:IsPenetrating() then
        Print( "defensive_props: PhysgunDrop: IsPenetrating" )
    end

    -- Freeze
    eProp:GetPhysicsObject():EnableMotion( false )

    local oProperty = eProp:GetProperty()
    if not oProperty then return end

    eProp:SetAngles( Angle( 0, eProp:GetAngles().y, 0 ) )
    eProp._bWasDropped = true

    -- @TODO: Do a custom sound
    -- eProp:EmitSound( "garrysmod/balloon_pop_cute.wav" )
end )

-- Decor Props
local DecorProps = PRP.Prop.Category.New("decor_props", "Decor Props", "icon16/palette.png" )

    local DecorProps_Paintings = DecorProps:NewChild("paintings", "Paintings", "icon16/photo.png")
    DecorProps_Paintings:AddModel( "models/maxofs2d/gm_painting.mdl" )

    local DecorProps_Plants = DecorProps:NewChild("plants", "Plants", "icon16/picture.png")
    DecorProps_Plants:AddModel( "models/props_lab/cactus.mdl" )

-- Furniture Props
local FurnitureProps = PRP.Prop.Category.New("furniture_props", "Furniture Props", "icon16/house.png")

    local FurnitureProps_Desks = FurnitureProps:NewChild("desks", "Desks")
    FurnitureProps_Desks:AddModel( "models/props_combine/breendesk.mdl" )

-- Structural Props
local StructuralProps = PRP.Prop.Category.New( "structural_props", "Structural Props", "icon16/building.png" )