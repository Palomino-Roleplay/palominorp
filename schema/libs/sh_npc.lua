PRP = PRP or {}
PRP.NPC = PRP.NPC or {}
PRP.NPC.List = PRP.NPC.List or {}

function PRP.NPC.LoadFromDir(directory)
    for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local niceName = v:sub(0, -5)

		NPC = PRP.NPC.List[niceName] or {}
			if (PLUGIN) then
				NPC.plugin = PLUGIN.uniqueID
			end

			ix.util.Include(directory.."/"..v, "shared")

			NPC.name = NPC.name or "Unknown"
			NPC.description = NPC.description or "No description available."

            PRP.NPC.Register( niceName, NPC, NPC.base or "Base" )
		NPC = nil
	end
end

PRP.NPC.Factory = PRP.NPC.Factory or {}
function PRP.NPC.Register( sType, tTable, sBase )
    tTable.Base = sBase or "Base"
    tTable._type = sTypeoNPC

    PRP.NPC.Factory[sType] = tTable
    baseclass.Set( "PRP.NPC." .. sType, tTable )

    local tMetatable = {}

    tMetatable.__index = function( t, k )
        if ( PRP.NPC.Factory[ tTable.Base ] and PRP.NPC.Factory[ tTable.Base ][k] ) then return PRP.NPC.Factory[ tTable.Base ][k] end
        return PRP.NPC.Factory["Base"][k]
    end

    setmetatable( tTable, tMetatable )

    return tTable
end

function PRP.NPC.GetByClass( sType )
    return PRP.NPC.Factory[sType]
end

function PRP.NPC.GetByID( iID )
    return PRP.NPC.List[iID]
end

-- Base NPC class
local PRP_NPC = {}

AccessorFunc( PRP_NPC, "name", "Name", FORCE_STRING )
AccessorFunc( PRP_NPC, "description", "Description", FORCE_STRING )

AccessorFunc( PRP_NPC, "title", "Title", FORCE_STRING )
AccessorFunc( PRP_NPC, "subtitle", "Subtitle", FORCE_STRING )

AccessorFunc( PRP_NPC, "_type", "Type" )

AccessorFunc( PRP_NPC, "_id", "ID" )
AccessorFunc( PRP_NPC, "_entity", "Entity" )
AccessorFunc( PRP_NPC, "_pos", "Pos", FORCE_VECTOR )
AccessorFunc( PRP_NPC, "_angles", "Angles", FORCE_ANGLE )

function PRP_NPC:Prepare()
end

function PRP_NPC:Init()
end

function PRP_NPC:Spawn()
    if SERVER then
        Print("hey!")
        self._entity = ents.Create( "prp_npc" )
        self._entity:SetPos( self._pos )
        self._entity:SetAngles( self._angles )

        self._entity:Spawn()
        self._entity:Activate()

        self._entity:SetType( self._type )
        self._entity:SetID( self:GetID() )

        self:SetEntity( self._entity )

        self:OnSpawn()

        return self._entity
    end
end

function PRP_NPC:OnSpawn()
end

function PRP_NPC:Use( eEntity )
    Print("use!")
    self:OnUse( eEntity )
end

function PRP_NPC:OnUse()
end

PRP.NPC.Factory["Base"] = PRP_NPC

PRP.NPC.List = {}
function PRP.NPC.Create( sType, sID )
    if sType == "Base" then return PRP.NPC.Factory["Base"] end

    if PRP.NPC.Factory[sType] then
        local tMetatable = PRP.NPC.Factory[sType]

        local oNPC = PRP.NPC.Create( tMetatable.Base, sID )
        oNPC.BaseClass = PRP.NPC.Factory[tMetatable.Base]
        oNPC._id = sID
        table.Merge( oNPC, tMetatable )

        oNPC:SetType( sType )
        oNPC:Prepare()

        -- PRP.NPC.List[sID] won't be accurate here.
        if oNPC.Init then oNPC:Init() end

        PRP.NPC.List[sID] = oNPC

        return oNPC
    end
end

if SERVER then
    function PRP.NPC.Setup()
        Print( "Setting up NPCs..." )
        if PRP.NPC.Spawned then
            for k, v in pairs( PRP.NPC.Spawned ) do
                SafeRemoveEntity( v )
            end
        end

        PRP.NPC.Spawned = {}

        for k, v in pairs( PRP.NPC.List ) do
            local eNPC = v:Spawn()
            table.insert( PRP.NPC.Spawned, eNPC )
        end
    end

    concommand.Add( "prp_npc_setup", function( pPlayer )
        if not pPlayer:IsDeveloper() then return end

        PRP.NPC.Setup()
    end )

    hook.Add( "InitPostEntity", "PRP.NPC.InitPostEntity", function()
        PRP.NPC.Spawned = {}

        PRP.NPC.Setup()
    end )

    hook.Add( "InitializedPlugins", "PRP.NPC.InitializedPlugins", function()
        -- @TODO: Remove
        if PRP.NPC.Spawned then
            PRP.NPC.Setup()
        end
    end )
end

-- Called when the NPC is initialized.

hook.Add( "DoPluginIncludes", "PRP.NPC.DoPluginIncludes", function( sPath, PLUGIN )
    PRP.NPC.LoadFromDir( sPath.."/npcs" )
end )


if SERVER then
    util.AddNetworkString( "PRP.NPC.Use" )
    concommand.Add( "prp_createnpc", function( pPlayer, sCmd, tArgs )
        -- if ( !pPlayer:IsSuperAdmin() ) then return end
        if not pPlayer:IsDeveloper() then return end
        if not SERVER then return end

        local trace = pPlayer:GetEyeTraceNoCursor()
        local ent = ents.Create( "prp_npc" )
        ent:SetPos( trace.HitPos )
        ent:Spawn()
        ent:Activate()

        if tArgs and #tArgs >= 1 then
            ent:SetType( tArgs[1] )
        end
    end )
end

if CLIENT then
    -- @TODO: Make this predicted.
    net.Receive( "PRP.NPC.Use", function()
        Print("received!")
        local eNPC = net.ReadEntity()

        if not eNPC or not eNPC:IsValid() then return end
        if not eNPC:GetNPC() then return end


        local oNPC = eNPC:GetNPC()
        if not oNPC then return end

        Print("using!")

        oNPC:Use( eNPC )
    end )
end