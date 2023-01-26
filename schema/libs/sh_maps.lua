hook.Add( "DoPluginIncludes", "PRP.Maps.DoPluginIncludes", function( sDirectory )
    ix.util.IncludeDir(sDirectory .. "/maps/" .. game.GetMap(), true)
end )