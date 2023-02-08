local PROPERTY = setmetatable( {}, { __index = PRP.Property.Meta } )

PROPERTY:SetID( "pd" )
PROPERTY:SetName( "Police Department" )
PROPERTY:SetFactions( {
    FACTION_POLICE
} )
PROPERTY:SetBounds(
    {
        {
            Vector(7423.96875,6656.1533203125,959.80999755859),
            Vector(9966.9873046875,9578.9296875,-636.59881591797),
        }
    }
)
Print( FACTION_POLICE )

print("testicle")

PRP.Property.Register( PROPERTY )
PROPERTY:Init()