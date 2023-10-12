PRP.Playtesting = PRP.Playtesting or {}

TrialObject = {}
TrialObject.__index = TrialObject

function TrialObject:New( name, description )
    local obj = {}
    setmetatable( obj, TrialObject )

    obj.name = name
    obj.description = description
    obj.vars = {}
    obj.startTime = os.time()
    obj.endTime = nil
    obj.players = {}
    obj.data = {}

    return obj
end
setmetatable( TrialObject, { __call = TrialObject.New } )

function TrialObject:Serialize()
    local tbl = {}

    tbl.name = self.name
    tbl.description = self.description
    tbl.vars = self.vars
    tbl.startTime = self.startTime
    tbl.endTime = self.endTime
    tbl.players = self.players
    tbl.data = self.data

    return markup.Escape( tbl )
end

function PRP.Playtesting.StartTrial()
    -- @TODO: We should handle this somewhere else
    if not file.IsDir( "palomino", "DATA" ) then
        file.CreateDir( "palomino" )
    end

    if not file.IsDir( "palomino/playtesting", "DATA" ) then
        file.CreateDir( "palomino/playtesting" )
    end

    local trialDate = os.date( "%Y-%m-%d_%H-%M-%S" )
    local trialFileName = "palomino/playtesting/" .. trialDate .. ".txt"
end