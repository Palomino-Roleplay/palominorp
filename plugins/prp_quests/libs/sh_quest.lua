PRP = PRP or {}
PRP.Quest = PRP.Quest or {}
PRP.Quest.List = PRP.Quest.List or {}

function PRP.Quest.Register( sID, tData )
    PRP.Quest.List[sID] = tData
end

function PRP.Quest.Get( sID )
    return PRP.Quest.List[sID]
end

function PRP.Quest.GetAll()
    return PRP.Quest.List
end

-- @TODO: Find a better spot for this
PRP.Quest.Register( "test1", {
    title = "test1",
    tasks = {
        
    }
} )

PRP.Quest.Register( "test11", {
    title = "test11",
    requires = "test1",
} )

PRP.Quest.Register( "test12", {
    title = "test12",
    requires = "test1",
} )

PRP.Quest.Register( "test121", {
    title = "test121",
    requires = "test12",
} )

PRP.Quest.Register( "test2", {
    title = "test2",
} )

PRP.Quest.Register( "test21", {
    title = "test21",
    requires = "test2",
} )