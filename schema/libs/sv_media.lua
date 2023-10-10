hook.Add( "InitPostEntity", "PRP.Media.InitPostEntity", function()
    -- @TODO: Fucking fuck fuck ew fuck this.

    timer.Create( "PRP.MediaPlayer.AutoAddAndRemoveTimer", 3, 0, function()
        for _, oMediaPlayer in ipairs( MediaPlayer.GetAll() ) do
            local tSeenPlayers = {}
            for _, pPlayer in ipairs( oMediaPlayer:GetListeners() ) do
                if not pPlayer:Alive() then return end

                if pPlayer:GetPos():DistToSqr( oMediaPlayer:GetPos() ) > ix.config.Get( "mediaPlayerDistance", 1000000 ) then
                    oMediaPlayer:RemoveListener( pPlayer )
                end

                tSeenPlayers[pPlayer:SteamID()] = true
            end

            for _, eEntity in ipairs( ents.FindInSphere( oMediaPlayer:GetPos(), ix.config.Get( "mediaPlayerDistance", 1000000 ) ) ) do
                if not IsValid( eEntity ) then continue end
                if not eEntity:IsPlayer() then continue end
                if oMediaPlayer:HasListener( eEntity ) then continue end

                oMediaPlayer:AddListener( eEntity )
            end
        end
    end )
end )