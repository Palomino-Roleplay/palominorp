PRP.Playtesting = PRP.Playtesting or {}

-- Names

local maleNames = {
    "James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph", "Charles", "Thomas",
    "Christopher", "Daniel", "Matthew", "Anthony", "Mark", "Paul", "Steven", "Andrew", "Kenneth", "Joshua",
    "Kevin", "Brian", "George", "Edward", "Ronald", "Timothy", "Jason", "Jeffrey", "Ryan", "Jacob",
    "Gary", "Nicholas", "Eric", "Stephen", "Jonathan", "Larry", "Justin", "Scott", "Frank", "Brandon",
    "Raymond", "Gregory", "Benjamin", "Samuel", "Patrick", "Alexander", "Jack", "Dennis", "Jerry", "Tyler",
    "Aaron", "Jose", "Henry", "Adam", "Douglas", "Zachary", "Walter", "Peter", "Ethan", "Nathan",
    "Zachary", "Harold", "Kyle", "Carl", "Arthur", "Gerald", "Roger", "Keith", "Jeremy", "Terry",
    "Lawrence", "Sean", "Christian", "Eddie", "Russell", "Gabriel", "Jordan", "Jesse", "Albert", "Billy"
}

local femaleNames = {
    "Mary", "Jennifer", "Linda", "Patricia", "Elizabeth", "Susan", "Jessica", "Sarah", "Karen", "Nancy",
    "Lisa", "Margaret", "Betty", "Sandra", "Ashley", "Dorothy", "Kimberly", "Emily", "Donna", "Michelle",
    "Carol", "Amanda", "Melissa", "Deborah", "Stephanie", "Rebecca", "Laura", "Helen", "Sharon", "Cynthia",
    "Kathy", "Amy", "Shirley", "Angela", "Anna", "Ruth", "Kathleen", "Brenda", "Pamela", "Nicole",
    "Samantha", "Barbara", "Julie", "Christine", "Martha", "Debra", "Diane", "Rachel", "Carolyn", "Janet",
    "Maria", "Heather", "Diane", "Virginia", "Kathryn", "Grace", "Judy", "Christina", "Joan", "Evelyn",
    "Cheryl", "Megan", "Andrea", "Olivia", "Tammy", "Crystal", "Sara", "Ann", "Rose", "Kelly",
    "Teresa", "Dawn", "Tiffany", "Renee", "Jacqueline", "Katherine", "Shannon", "Erica", "Holly", "Courtney"
}

local lastNames = {
    "Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor",
    "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson",
    "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King",
    "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter",
    "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins",
    "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey",
    "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez",
    "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross"
}

function PRP.Playtesting.CreateSampleCharacter( pPlayer, fnCallback )
    local bIsMale = math.random( 1, 2 ) == 1

    local sModel
    if bIsMale then
        sModel = "models/player/group01/male_0" .. math.random( 1, 9 ) .. ".mdl"
    else
        sModel = "models/player/Group01/Female_0" .. math.random( 1, 6 ) .. ".mdl"
    end

    local tCharacterInfo = {
        name = (bIsMale and maleNames[ math.random( #maleNames ) ] or femaleNames[ math.random( #femaleNames ) ]) .. " " .. lastNames[ math.random( #lastNames ) ],
        model = sModel,
        steamID = pPlayer:SteamID64(),
        faction = "Citizen",
    }

    ix.char.Create( tCharacterInfo, function( iID )
        local oCharacter = ix.char.loaded[iID]

        if not oCharacter then
            ErrorNoHalt( "Failed to create character for " .. pPlayer:Name() .. " (" .. pPlayer:SteamID() .. ")" )
            return
        end

        local oCurrentCharacter = pPlayer:GetCharacter()

        if oCurrentCharacter then
            oCurrentCharacter:Save()

            for _, v in ipairs( oCurrentCharacter:GetInventory( true ) ) do
                if ( istable(v) ) then
                    v:RemoveReceiver( pPlayer )
                end
            end
        end

        hook.Run( "PrePlayerLoadedCharacter", pPlayer, oCharacter, oCurrentCharacter )

        oCharacter:Setup()
        pPlayer:Spawn()

        hook.Run( "PlayerLoadedCharacter", pPlayer, oCharacter, oCurrentCharacter )

        if fnCallback then
            fnCallback( pPlayer, oCharacter )
        end
    end )
end

-- DistributionObject

DistributionObject = {}
DistributionObject.__index = DistributionObject

function DistributionObject:New( fnDistribution )
    local obj = {}
    setmetatable( obj, DistributionObject )

    obj.Generate = fnDistribution
    obj.__call = obj.Generate

    return obj
end

-- NormalDistributionObject - Normal

NormalDistributionObject = DistributionObject:New( function( this )
    -- Generate two uniform random numbers between 0 and 1
    local u1 = math.random()
    local u2 = math.random()

    -- Use the Box-Muller transform to get the normal random variable
    local z0 = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    -- local z1 = math.sqrt(-2 * math.log(u1)) * math.sin(2 * math.pi * u2) -- Note: z1 is another independent normally distributed number

    -- Scale and shift the result to have the desired mean and standard deviation
    return z0 * this.std + this.mean
end )

function NormalDistributionObject:New( mean, std )
    local obj = {}
    setmetatable( obj, NormalDistributionObject )

    obj.mean = mean
    obj.std = std

    return obj
end

-- TrialObject

TrialObject = {}
TrialObject.__index = TrialObject

function TrialObject:New( name )
    local obj = {}
    setmetatable( obj, TrialObject )

    obj.name = name
    obj.vars = {}
    obj.startTime = os.time()
    obj.endTime = nil
    obj.players = {}
    obj.characters = {}
    obj.data = {}

    return obj
end
setmetatable( TrialObject, { __call = TrialObject.New } )

function TrialObject:Serialize()
    local tbl = {}

    tbl.name = self.name
    tbl.startTime = self.startTime
    tbl.endTime = self.endTime or 0
    tbl.players = util.TableToJSON( self.players )
    tbl.characters = util.TableToJSON( self.characters )
    tbl.vars = util.TableToJSON( self.vars )
    tbl.data = util.TableToJSON( self.data )

    return util.TableToJSON( tbl )
end

function TrialObject:AddVar( sClass, oDistribution, fnCallback )
    self.vars[sClass] = {
        distribution = oDistribution,
        callback = fnCallback
    }

    self.vars[sClass].value = self.vars[sClass].distribution()
end

function TrialObject:AddVarManual( sClass, xValue )
    self.vars[sClass] = self.vars[sClass] or {}
    self.vars[sClass].value = xValue
end


function TrialObject:GetVar( sClass )
    return self.vars[sClass].value
end

function TrialObject:AddPlayer( pPlayer )
    table.insert( self.players, pPlayer )
end

function TrialObject:RemovePlayer( pPlayer )
    table.RemoveByValue( self.players, pPlayer )
end

function TrialObject:AssignPlayers()
    local iNumPolice = math.floor( self:GetVar( "percent_police" ) * #self.players )

    local tPolice = table.Random( self.players, iNumPolice )
    local tRobbers = table.Copy( self.players )
    for _, pPlayer in ipairs( tPolice ) do
        table.RemoveByValue( tRobbers, pPlayer )

        pPlayer:Notify( "You will play as a Police Officer" )
        pPlayer:SetLocalVar( "PRP.Playtesting.Role", "cop" )
        pPlayer:SetLocalVar( "PRP.Playtesting.Objective", tScenes[1].roles["cop"].objective )
    end

    for _, pPlayer in ipairs( tRobbers ) do
        pPlayer:Notify( "You will play as a Robber" )
        pPlayer:SetLocalVar( "PRP.Playtesting.Role", "robber" )
        pPlayer:SetLocalVar( "PRP.Playtesting.Objective", tScenes[1].roles["robber"].objective )
    end

end

function TrialObject:Log( sEventType, tData )
    table.insert( self.data, {
        time = os.time(),
        type = sEventType,
        data = tData
    } )
end

function TrialObject:Initialize()
    -- for sClass, tVar in pairs( self.vars ) do
    --     if tVar.value then continue end
    --     tVar.value = tVar.distribution()
    --     tVar.callback( tVar.value )
    -- end

    for _, pPlayer in ipairs( player.GetAll() or {} ) do
        table.insert( self.players, pPlayer:SteamID64() )
        PRP.Playtesting.CreateSampleCharacter( pPlayer, function( iID )
            table.insert( self.characters, iID )
        end )
    end
end

function TrialObject:Start()
    self.startTime = os.time()

    for _, pPlayer in ipairs( player.GetAll() or {} ) do
        pPlayer:Notify( "The trial has started." )
    end
end

local function fnSendTrialData( oTrial )
    -- https://discord.com/api/webhooks/1161915559827488899/vjuzr9hxUYaDWHQOB7xD1gd3a4Zgg_uk_xh-4UfRlDgsCFiWraY-agNFKndhAoS1jl_0

    if not file.IsDir( "palomino", "DATA" ) then
        file.CreateDir( "palomino" )
    end

    if not file.IsDir( "palomino/playtesting", "DATA" ) then
        file.CreateDir( "palomino/playtesting" )
    end

    local sFileName = "palomino/playtesting/" .. os.date( "%Y-%m-%d_%H-%M-%S" ) .. ".json"
    file.Write( sFileName, oTrial:Serialize() )
end

function TrialObject:Complete()
    self.endTime = os.time()

    for _, pPlayer in ipairs( player.GetAll() or {} ) do
        pPlayer:Notify( "The trial has ended." )
    end

    fnSendTrialData( self )
end


local oPoliceRankDistribution = NormalDistributionObject:New( 3, 1 )
local tRanks = {
    [1] = CLASS_POLICE_CADET,
    [2] = CLASS_POLICE_OFFICER,
    [3] = CLASS_POLICE_SERGEANT,
    [4] = CLASS_POLICE_LIEUTENANT,
    [5] = CLASS_POLICE_CHIEF,
}

local tScenes = {
    {
        id = "bank",
        roles = {
            ["cop"] = {
                objective = "Arrest the robbers and secure the bank.",
                spawns = {
                    ["timely_response"] = {
                        { pos = Vector( -1891, 1903, -104 + 16 ) },
                        { pos = Vector( -1233, 1895, -104 + 16 ) },
                        { pos = Vector( -1364, 1996, -104 + 16 ) },
                        { pos = Vector( -1656, 1903, -104 + 16 ) },
                        { pos = Vector( -2146, 2684, -104 + 16 ) },
                        { pos = Vector( -2146, 2274, -104 + 16 ) },
                    }
                },

                PreSpawn = function( pPlayer )
                    local oCharacter = pPlayer:GetCharacter()
                    oCharacter:SetFaction( FACTION_POLICE )

                    local iRandomNumberForRank = math.floor( math.Clamp( oPoliceRankDistribution:Generate(), 1, 5 ) ) + 1
                    local iRankID = tRanks[iRandomNumberForRank]

                    oCharacter:SetClass( iRankID )
                end,

                PostSpawn = function( pPlayer )
                    local oCharacter = pPlayer:GetCharacter()
                end
            },

            ["robber"] = {
                objective = "Rob the bank and escape with the money.",
                spawns = {
                    ["whereever"] = {
                        -- Security Room
                        { pos = Vector( -1023, 3061, -104 ) },
                        -- Bank Lobby
                        { pos = Vector( -765, 2359, -104 ) },
                        -- Behind First Doors
                        { pos = Vector( -504, 2477, -104 ) },
                        { pos = Vector( -578, 2519, -104 ) },
                        -- Bank Counter
                        { pos = Vector( -1079, 2869, -104 ) },
                        -- Past Lasers
                        { pos = Vector( -483, 3319, -104 ) },
                        -- Pre-Vault
                        { pos = Vector( -1178, 3202, -280 ) },
                        -- Vault
                        { pos = Vector( -1561, 3185, -280 ) },
                    }
                },

                PreSpawn = function( pPlayer )
                end,

                PostSpawn = function( pPlayer )
                    local oCharacter = pPlayer:GetCharacter()
                    local oInventory = oCharacter:GetInventory()

                    local iRandomValueWeapon = math.random()

                    local sWeaponID = ""

                    if iRandomValueWeapon < 0.1 then
                        -- 10% chance of m3
                        sWeaponID = "M3 Super 90"
                    elseif iRandomValueWeapon < 0.4 then
                        -- 30% chance of m4
                        sWeaponID = "M4A1 Carbine"
                    elseif iRandomValueWeapon < 0.9 then
                        -- 50% chance of sks
                        sWeaponID = "SKS"
                    else
                        -- 10% chance of scar
                        sWeaponID = "SCAR-H"
                    end

                    oInventory:Add( sWeaponID, 1 )
                    pPlayer:Notify( "You have been given a " .. sWeaponID .. ". Equip it in your inventory by pressing TAB." )
                end
            }
        },
    },
}


PRP.Playtesting.CurrentTrial = nil
function PRP.Playtesting.StartTrial()
    -- @TODO: We should handle this somewhere else
    if not file.IsDir( "palomino", "DATA" ) then
        file.CreateDir( "palomino" )
    end

    if not file.IsDir( "palomino/playtesting", "DATA" ) then
        file.CreateDir( "palomino/playtesting" )
    end

    PRP.Playtesting.CurrentTrial = TrialObject:New()
    PRP.Playtesting.CurrentTrial:AddVar( "percent_police", NormalDistributionObject:New( 0.5, 0.15 ) )
    PRP.Playtesting.CurrentTrial:AddVarManual( "scene", tScenes[math.random( #tScenes )] )
    PRP.Playtesting.CurrentTrial:Initialize()

    PRP.Playtesting.CurrentTrial:Start()
end