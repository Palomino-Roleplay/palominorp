local UPGRADE = {}

AccessorFunc( UPGRADE, "m_strID", "ID", FORCE_STRING )
AccessorFunc( UPGRADE, "m_strName", "Name", FORCE_STRING )

PRP.Metatable = PRP.Metatable or {}

PRP.Metatable.UPGRADE = UPGRADE