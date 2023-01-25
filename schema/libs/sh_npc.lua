PRP = PRP or {}
PRP.NPC = PRP.NPC or {}
PRP.NPC.List = PRP.NPC.List or {}

function PRP.NPC.LoadFromDir(directory)
    for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local niceName = v:sub(4, -5)

		NPC = PRP.NPC.List[niceName] or {}
			if (PLUGIN) then
				NPC.plugin = PLUGIN.uniqueID
			end

			ix.util.Include(directory.."/"..v)

			NPC.name = NPC.name or "Unknown"
			NPC.description = NPC.description or "No description availalble."

			PRP.NPC.List[niceName] = NPC
		NPC = nil
	end
end

hook.Add( "DoPluginIncludes", "PRP.NPC.DoPluginIncludes", function( sPath, PLUGIN )
    PRP.NPC.LoadFromDir( sPath.."/NPC" )
end )

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
        ent:SetNPC( tArgs[1] )
    end
end )