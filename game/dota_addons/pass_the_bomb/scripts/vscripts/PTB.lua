if not PTB then
	PTB = { }
end

PTB.STATE_PREROUND  = 1
PTB.STATE_ROUND     = 2
PTB.STATE_POSTROUND = 3

PTB.RoundLimit = 5
PTB.RoundTime = 15
PTB.NewRoundTime = 10
PTB.NewMatchTime = 30

PTB.AddedAI = false
PTB.Testing = false
PTB.HasFirstClient = false

--[[
--   Initialization
--]]

function PTB:Init()
	if PTB.Inited then
		print( "Pass The Bomb already initialized, skipping." )
		return
	end

	print( "Initializing Pass The Bomb" )

	print( "Loading modules:" )
	LoadModule( "Bomb" )
	LoadModule( "Player" )
	LoadModule( "PlayerRegistry" )
	LoadModule( "Teams" )
	LoadModule( "Timers" )

	PlayerRegistry:Init()

	PTB.LastTick = GameRules:GetGameTime()
	PTB.ModeNames = {
		"Normal",

		"Blink", "Casket", "Forest",
		"Night", "Rooted", "Speed",
		"SuperNight", "Toss"
	}
	PTB.Players = { }
	PTB.State = PTB.STATE_PREROUND

	local time_txt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(time_txt))

	print( "Adding game event listeners" )

	ListenToGameEvent( 'dota_item_picked_up', Dynamic_Wrap( PTB, 'EventItemPickup' ),         PTB )
	ListenToGameEvent( 'dota_player_gained_level', Dynamic_Wrap( PTB, 'EventGainLevel' ),     PTB )
	ListenToGameEvent( 'entity_killed',       Dynamic_Wrap(PTB, 'EventEntityKilled'),         PTB )
	ListenToGameEvent( 'game_rules_state_change', Dynamic_Wrap( PTB, 'EventStateChanged' ),   PTB )
	ListenToGameEvent( 'player_connect',      Dynamic_Wrap( PTB, 'EventPlayerConnected' ),    PTB )
	ListenToGameEvent( 'player_connect_full', Dynamic_Wrap( PTB, 'EventPlayerJoined' ),       PTB )
	ListenToGameEvent( 'player_team',         Dynamic_Wrap( PTB, 'EventPlayerJoinedTeam' ),   PTB )
	ListenToGameEvent( 'player_disconnect',   Dynamic_Wrap( PTB, 'EventPlayerDisconnected' ), PTB )
	ListenToGameEvent( 'player_reconnected',  Dynamic_Wrap( PTB, 'EventPlayerReconnected' ),  PTB )
	ListenToGameEvent( 'ptb_bomb_passed',     Dynamic_Wrap( PTB, 'EventBombPassed' ),         PTB )
	ListenToGameEvent( 'npc_spawned',         Dynamic_Wrap( PTB, 'EventNPCSpawned' ),         PTB )

	PTB:AddStateHandler( DOTA_GAMERULES_STATE_HERO_SELECTION, function()
		Timers:CreateTimer( 4, function()
			if not PlayerResource:HaveAllPlayersJoined() then return 1 end

			PTB:EventPlayersAllJoined()
		end )
	end )

	PTB:AddStateHandler( DOTA_GAMERULES_STATE_PRE_GAME, function() 
		Timers:CreateTimer( function()
			for i = 0, PlayerResource:GetPlayerCount() - 1 do
				local ply = PlayerResource:GetPlayer( i )
				if IsValidEntity( ply ) and
				   not ply.Player then
					print( i .. " doesn't have a hero yet, waiting" )
					return 0.5
				end
			end

			print( "All players have heroes, reassigning teams." ) 

			PTB:_EnsureTeams()
		end )
	end )

	PTB:AddStateHandler( DOTA_GAMERULES_STATE_GAME_IN_PROGRESS, function() 
		PTB:BeginRound( true )
	end )

	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	GameRules:SetCustomVictoryMessage( "Boom! Hahahaha" )

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetPreGameTime( 30 )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetFirstBloodActive( false )
	GameRules:SetUseCustomHeroXPValues( true )

	-- Gamemode settings
	local gamemode = GameRules:GetGameModeEntity()
	gamemode:SetAnnouncerDisabled( true )
	gamemode:SetBuybackEnabled( false )
	gamemode:SetCustomGameForceHero( "npc_dota_hero_techies" )

	-- Load modes
	print( "Loading modes:" )
	PTB.Modes = {}
	for _, name in pairs( PTB.ModeNames ) do
		PTB.Modes[name] = LoadModule( "Modes." .. name )
	end

	print( "Creating Da Bomb" )

	PTB.Bomb = Bomb()
	PTB.Bomb:Drop()

	PTB.Inited = true
end


--[[
--   Round handling
--]]

function PTB:PickMode()
	if not PTB.LastMode then
		return PTB.Modes.Normal -- Always start on normal mode
	else
		local alive = PlayerRegistry:GetAlivePlayers()

		-- Only normal mode on the last 1 v 1
		if #alive == 2 then return PTB.Modes.Normal end

		local total = PlayerRegistry:GetAllPlayers()
		local perc = #alive / #total

		-- Don't run the same mode two times in a row
		local newMode = PTB.LastMode
		repeat
			newMode = PTB.Modes[ PTB.ModeNames[ math.random( #PTB.ModeNames ) ] ]
		until newMode ~= PTB.LastMode and perc >= ( newMode.Min or 0 )

		print( "Old mode: " .. PTB.LastMode.Name .. ", New mode: " .. newMode.Name )

		return newMode
	end
end

function PTB:BeginRound( skip_time )
	PTB.State = PTB.STATE_PREROUND
	PTB.CurMode = PTB:PickMode()
	PTB.CurMode:Init()

	if not skip_time then
		--PTB.Bomb:Drop()

		Say( nil, PTB.CurMode.Name .. " mode in " .. PTB.NewRoundTime .. " seconds...", false )
	end

	Timers:CreateTimer( skip_time and 0 or PTB.NewRoundTime, function() 
		PTB.Bomb:Take()
		PTB.State = PTB.STATE_ROUND

		PTB.CurMode.StartTime = GameRules:GetGameTime()
		PTB.CurMode:Start()

		local living = PlayerRegistry:GetAlivePlayers()
		local luckyGuy = living[ math.random( #living ) ]
		PTB.Bomb:Pass( luckyGuy )

		Say( nil, luckyGuy.Name .. " is the lucky guy.", false)
	end )
end

function PTB:EndRound()
	if not PTB.CurMode then return end

	PTB.State = PTB.STATE_POSTROUND
	local mode = PTB.CurMode
	PTB.CurMode = nil

	mode:Cleanup()

	PTB.LastMode = mode

	local alive = PlayerRegistry:GetAlivePlayers()
	if #alive == 1 then
		local survivor = alive[ 1 ]
		Say( nil, survivor.Name .. " survived this one, next match in " .. PTB.NewMatchTime .. " seconds", false )
		survivor.Score = survivor.Score + 1
		survivor.HeroEntity:HeroLevelUp( true )

		if survivor.Score >= PTB.RoundLimit then
			Say( nil, survivor.Name .. " has proven to be a cockroach by surviving " .. PTB.RoundLimit .. " matches!", false )
			Timers:CreateTimer( 1, function() 
				GameRules:SetGameWinner( survivor.Team )
			end )
		end
	elseif #alive == 0 then
		Say( nil, "You all died, that's pretty sad...", false )
		Say( nil, "Next match in " .. PTB.NewMatchTime .. " seconds.", false )
	end

	if #alive <= 1 then
		Timers:CreateTimer( ( PTB.NewMatchTime - PTB.NewRoundTime ), function() 
			for _,p in pairs( PlayerRegistry:GetDeadPlayers( { Connected = true } ) ) do
				if p.State == Player.STATE_CONNECTED then
					p.HeroEntity:RespawnHero( false, false, false )
				end
			end

			PTB:BeginRound()
		end )
	else
		Timers:CreateTimer( 1, function()
			PTB:BeginRound()
		end )
	end
end


--[[
--   Player handling
--]]

function PTB:ExplodePlayer( player, caster )
	print( player.Name .. " goes asplodey" )

	local ability = player:GetAbility( "techies_explode" )
	ability:SetLevel( 1 )
	ability:CastAbility()
	ability:SetLevel( 0 )

	player.HeroEntity:Kill( caster:GetAbility( "techies_pass_the_bomb" ), caster.HeroEntity )
end


--[[
--   State management
--]]

function PTB:AddStateHandler( state, func )
	if not PTB.States then PTB.States = { } end
	if not PTB.States[ state ] then PTB.States[ state ] = { } end

	local stateList = PTB.States[ state ]

	stateList[ #stateList + 1 ] = func
	return #stateList
end

function PTB:RemoveStateHandler( state, handlerID )
	if not PTB.States then return end
	if not PTB.States[ state ] then return end

	PTB.States[ state ][ handlerID ] = nil
end

function PTB:_OnState( state )
	if not PTB.States then return end
	if not PTB.States[ state ] then return end

	for k, f in pairs( PTB.States[ state ] ) do
		local status, err = pcall( f )

		if not status then
			print( "State manager " .. k ..  " failed for state " .. state )
		end
	end
end


--[[
--   Testing functionality
--]]

function PTB:TestingClients()
	if not PTB.Testing or not PTB.HasFirstClient or PTB.AddedAI then return end

	PTB.AddedAI = true

	SendToServerConsole('dota_create_fake_clients')
	Timers:CreateTimer( 1, function() 
		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsFakeClient( i ) then
				local ply = PlayerResource:GetPlayer( i )

				PTB:EventPlayerJoined( { 
					userid = i + 1,
					index  = ply:entindex() - 1
				} )
			end
		end
	end )
end


--[[
--   Helper functions
--]]

function PTB:_EnsureTeams()
	Teams:Init()
	CustomGameEventManager:Send_ServerToAllClients( "ptb_teams_changed", { } )

	for _, ply in pairs( PlayerRegistry:GetAllPlayers() ) do
		ply:SetTeam( Teams.TeamIDs[ ply.ID ] )

		ply.HeroEntity:RespawnHero( false, true, false )
	end
end


--[[
--   Event handling
--]]

function PTB:EventBombPassed( event )
	print( "PTB:EventBombPassed" )
	-- PrintTable( event )
end

function PTB:EventEntityKilled( event )
	print( "PTB:EventEntityKilled" )
	-- PrintTable( event )

	local attacker = EntIndexToHScript( event.entindex_attacker )
	local killed = EntIndexToHScript( event.entindex_killed )

	if IsValidEntity( attacker ) and attacker.Player then
		attacker.Player:OnKilled( event )
	end
	if IsValidEntity( killed ) and killed.Player then
		killed.Player:OnDied( event )
	end
end

function PTB:EventGainLevel( event )
	print( "PTB:EventGainLevel" )
	-- PrintTable( event )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:OnGainedLevel( event )
	end

	-- FIXME: Why does this not always work?
	--[[
	local player = PlayerRegistry:GetPlayer( {
		UserID = PlayerResource:GetPlayer( event.player - 1 ):GetPlayerID()
	} )

	if player then player:OnGainedLevel( event ) end
	]]
end

function PTB:EventItemPickup( event )
	print( "PTB:EventItemPickup" )
	-- PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		UserID = event.PlayerID
	} )

	if player then player:OnItemPickedup( event ) end
end

function PTB:EventNPCSpawned( event )
	print( "PTB::EventNPCSpawned" )
	-- PrintTable( event )

	local npc = EntIndexToHScript( event.entindex )

	if not IsValidEntity( npc) or not npc:IsHero() then return end

	local player = npc.Player or nil

	if not player then
		print( "Creating player for ID " .. npc:GetPlayerOwnerID() )
		player = PlayerRegistry:RegisterPlayer( Player.Create( npc:GetPlayerOwnerID() ) )
	end

	player:OnSpawned( event )
end

function PTB:EventPlayerConnected( event )
	print( "PTB:EventPlayerConnected" )
	-- PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		UserID = event.userid - 1
	} )

	if player then player:OnConnected( event ) end

end

local playerCount = 0
function PTB:EventPlayerJoined( event )
	print( "PTB:EventPlayerJoined" )
	-- PrintTable( event )

	playerCount	= playerCount + 1

	local ply = EntIndexToHScript( event.index + 1 )
	local id = playerCount

	print( "Player #" .. id .. " connected." )

	ply:SetTeam( DOTA_TEAM_GOODGUYS )

	--PrecacheUnitByNameAsync( 'npc_dota_hero_techies', function() print( 'Techies precached!' ) end )

	PTB.HasFirstClient = true
	PTB:TestingClients()
end

function PTB:EventPlayerDisconnected( event )
	print( "PTB:EventPlayerDisconnected" )
	-- PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		UserID = event.userid - 1
	} )

	if player then player:OnDisconnected( event ) end
end

function PTB:EventPlayerJoinedTeam( event )
	print( "PTB:EventPlayerJoinedTeam" )
	-- PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		UserID = event.userid - 1
	} )

	if player then
		print( "OnJoinedTeam" )
		player:OnJoinedTeam( event )
	else
		print( "Priming name \"" .. event.name .. "\" for " .. (event.userid - 1) )
		PlayerRegistry:PrimeName( event.userid - 1, event.name )
	end
end

function PTB:EventPlayersAllJoined()
	print( "PTB:EventPlayersAllJoined" )
end

function PTB:EventStateChanged( event )
	print( "PTB:EventStateChanged" )
	-- PrintTable( event )

	local state = GameRules:State_Get()
	PTB:_OnState( state )
end
