PRP = PRP or {}
PRP.Skills = PRP.Skills or {}
PRP.Skills.List = PRP.Skills.List or {}

function PRP.Skills.LoadFromDir(directory)
    for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local niceName = v:sub(4, -5)

		SKILL = PRP.Skills.List[niceName] or {}
			if (PLUGIN) then
				SKILL.plugin = PLUGIN.uniqueID
			end

			ix.util.Include(directory.."/"..v)

			SKILL.name = SKILL.name or "Unknown"
			SKILL.description = SKILL.description or "No description availalble."

			PRP.Skills.List[niceName] = SKILL
		SKILL = nil
	end
end

hook.Add( "DoPluginIncludes", "PRP.Skills.DoPluginIncludes", function( sPath, PLUGIN )
    PRP.Skills.LoadFromDir( sPath.."/skills" )
end )