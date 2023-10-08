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