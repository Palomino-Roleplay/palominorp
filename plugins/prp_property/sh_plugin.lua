local PLUGIN = PLUGIN

PLUGIN.name = "Property System"
PLUGIN.author = "sil"
PLUGIN.description = ""

-- @TODO: Do this config better (maybe in the menu)
PLUGIN.config = {
    limits = {
        total = 2,
        category = {
            ["commercial"] = 1,
            ["residential"] = 1,
            ["industrial"] = 1
        }
    },

    props = {
        ["defensive_props"] = {
            categoryID = "defensive_props",
            name = "Defensive Props",
            icon = "icon16/bomb.png",

            subcategories = {
                ["small"] = {
                    categoryID = "defensive_props/small",
                    name = "Small",

                    models = {
                        ["models/mosi/fallout4/props/fortifications/gravelwall.mdl"] = {
                            bodygroups = "010000000",
                            snapPoints = {
                                {
                                    point = Vector( 0, 40, 44 ),
                                    angleGrid = Angle( 360, 180, 360 ),
                                },
                                {
                                    point = Vector( 0, -42, 44 ),
                                    angleGrid = Angle( 360, 180, 360 ),
                                },
                            }
                        },
                    },
                },

                ["medium"] = {
                    categoryID = "defensive_props/medium",
                    name = "Medium",

                    models = {
                        ["models/props_fortifications/sandbags_corner1.mdl"] = {},
                        ["models/props_fortifications/sandbags_corner1_tall.mdl"] = {},
                        ["models/props_fortifications/sandbags_line1.mdl"] = {},
                        ["models/props_fortifications/sandbags_line1_tall.mdl"] = {},
                    },
                },

                ["large"] = {
                    categoryID = "defensive_props/large",
                    name = "Large",

                    models = {
                        ["models/props_fortifications/sandbags_corner2.mdl"] = {},
                        ["models/props_fortifications/sandbags_corner2_tall.mdl"] = {},
                        ["models/props_fortifications/sandbags_line2.mdl"] = {},
                        ["models/props_fortifications/sandbags_line2_tall.mdl"] = {},
                    }
                }
            },

            OnSpawn = function( eProp, pPlayer, sModel, tModelConfig )
                constraint.Keepupright( eProp, Angle( 0, 90, 0 ), 0, 9999999 )

                local oPhysics = eProp:GetPhysicsObject()
                if not oPhysics then return end

                oPhysics:EnableMotion( false )
            end,

            PhysgunDrop = function( eProp, pPlayer )
                -- Print( "defensive_props: PhysgunDrop" )
                -- Print( eProp )
                -- Print( pPlayer )

                local oPhysics = eProp:GetPhysicsObject()

                if not oPhysics then return end

                -- See GM:OnPhysgunFreeze
                oPhysics:EnableMotion( false )

                -- if oPhysics:IsPenetrating() then
                --     Print( "defensive_props: PhysgunDrop: IsPenetrating" )
                --     return false
                -- end

                -- Freeze
                eProp:GetPhysicsObject():EnableMotion( false )

                local oProperty = eProp:GetProperty()
                if not oProperty then return end

                local iFloorZ = oProperty:GetFloorZ()
                local iPropZ = eProp:GetPos().z

                eProp:SetPos( Vector( eProp:GetPos().x, eProp:GetPos().y, iFloorZ ) )
                eProp._bWasDropped = true
                -- @TODO: Do a custom sound
                eProp:EmitSound( "garrysmod/balloon_pop_cute.wav" )
            end,
        },

        ["decor_props"] = {
            categoryID = "decor_props",
            name = "Decor Props",
            icon = "icon16/palette.png",

            subcategories = {
                ["paintings"] = {
                    categoryID = "decor_props/paintings",
                    name = "Paintings",
                    icon = "icon16/photo.png",

                    models = {
                        ["models/props/cs_office/offcertificatea.mdl"] = {},
                        ["models/props/cs_office/offcorkboarda.mdl"] = {},
                        ["models/props/cs_office/offpaintinga.mdl"] = {},
                        ["models/props/cs_office/offpaintingb.mdl"] = {},
                        ["models/props/cs_office/offpaintingd.mdl"] = {},
                        ["models/props/cs_office/offpaintinge.mdl"] = {},
                        ["models/props/cs_office/offpaintingf.mdl"] = {},
                        ["models/props/cs_office/offpaintingg.mdl"] = {},
                        ["models/props/cs_office/offpaintingh.mdl"] = {},
                        ["models/props/cs_office/offpaintingi.mdl"] = {},
                        ["models/props/cs_office/offpaintingj.mdl"] = {},
                        ["models/props/cs_office/offpaintingk.mdl"] = {},
                        ["models/props/cs_office/offpaintingl.mdl"] = {},
                        ["models/props/cs_office/offpaintingo.mdl"] = {},
                    },
                },

                ["technology"] = {
                    categoryID = "decor_props/technology",
                    name = "Technology",
                    icon = "icon16/computer.png",

                    models = {
                        ["models/props_lab/monitor01a.mdl"] = {},
                        ["models/props_lab/monitor02.mdl"] = {},
                        ["models/props_lab/harddrive02.mdl"] = {},
                        ["models/props_lab/harddrive01.mdl"] = {},
                    },
                },

                ["plants"] = {
                    categoryID = "decor_props/plants",
                    name = "Plants",
                    icon = "icon16/picture.png",

                    models = {
                        ["models/props/cs_office/plant01.mdl"] = {},
                        ["models/props_lab/cactus.mdl"] = {},
                        ["models/props/de_tides/planter.mdl"] = {},
                        ["models/props/de_inferno/potted_plant1.mdl"] = {},
                        ["models/props/de_inferno/potted_plant2.mdl"] = {},
                        ["models/props/de_inferno/potted_plant3.mdl"] = {},
                    },
                },

                ["misc"] = {
                    categoryID = "decor_props/misc",
                    name = "Miscellaneous",
                    icon = "icon16/cake.png",

                    models = {
                        ["models/props_lab/huladoll.mdl"] = {},
                        ["models/maxofs2d/companion_doll.mdl"] = {},
                    },
                },
            },

            OnSpawn = function( eProp, pPlayer, sModel, tModelConfig )
                eProp:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
            end
        },

        ["structural_props"] = {
            categoryID = "structural_props",
            name = "Structural Props",
            icon = "icon16/building.png",

            subcategories = {
                ["blocks"] = {
                    categoryID = "structural_props/blocks",
                    name = "Blocks",
                    icon = "icon16/brick.png",

                    models = {
                        ["models/hunter/blocks/cube075x075x075.mdl"] = {},
                        ["models/hunter/blocks/cube075x1x075.mdl"] = {},
                        ["models/hunter/blocks/cube075x1x1.mdl"] = {},
                        ["models/hunter/blocks/cube1x1x1.mdl"] = {},
                    },
                },

                ["tubes"] = {
                    categoryID = "structural_props/tubes",
                    name = "Tubes",
                    icon = "icon16/brick.png",

                    models = {
                        ["models/hunter/tubes/tube1x1x2.mdl"] = {},
                        ["models/hunter/tubes/tube1x1x3.mdl"] = {},
                        ["models/hunter/tubes/tube1x1x1.mdl"] = {},
                    },
                },
            },
        },

        ["furniture_props"] = {
            categoryID = "furniture_props",
            name = "Furniture Props",
            icon = "icon16/house.png",

            subcategories = {
                ["desks"] = {
                    categoryID = "furniture_props/desks",
                    name = "Desks",

                    models = {
                        ["models/props_combine/breendesk.mdl"] = {},
                        ["models/props_interiors/Furniture_Desk01a.mdl"] = {},
                        ["models/props_wasteland/controlroom_desk001b.mdl"] = {},
                        ["models/props_wasteland/controlroom_desk001a.mdl"] = {},
                    },
                },

                ["couches"] = {
                    categoryID = "furniture_props/couches",
                    name = "Couches",

                    models = {
                        ["models/props_interiors/Furniture_Couch01a.mdl"] = {},
                        ["models/props_interiors/Furniture_Couch02a.mdl"] = {},
                        ["models/props/cs_office/sofa.mdl"] = {},
                        ["models/props/cs_office/sofa_chair.mdl"] = {},
                        ["models/props/CS_militia/couch.mdl"] = {},
                    },
                },
            },
        }
    }
}

ix.util.Include( "meta/cl_spawnmenu.lua" )
ix.util.Include( "meta/sh_character.lua" )
ix.util.Include( "meta/sh_entity.lua" )
ix.util.Include( "meta/sh_property.lua" )
ix.util.Include( "meta/sv_entity.lua" )
ix.util.Include( "meta/sv_property.lua" )

ix.util.Include( "hooks/cl_physgun.lua" )
ix.util.Include( "hooks/cl_property.lua" )
ix.util.Include( "hooks/sh_physgun.lua" )
ix.util.Include( "hooks/sh_property.lua" )
ix.util.Include( "hooks/sh_props.lua" )
ix.util.Include( "hooks/sv_physgun.lua" )
ix.util.Include( "hooks/sv_property.lua" )
ix.util.Include( "hooks/sv_props.lua" )

ix.config.Add("propertyRentPaymentInterval", 15, "How many minutes are there between the rent payments? (Needs map change to update)", nil, {
    data = {min = 1, max = 60, decimals = 0},
    category = "Palomino: Property"
})

ix.config.Add("propertySpawnmenuCooldown", 3, "How many seconds before players can attempt to spawn a prop via the spawnmenu again?", nil, {
    data = {min = 1, max = 10, decimals = 0},
    category = "Palomino: Property"
})