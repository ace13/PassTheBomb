if not PTB then
	PTB = { }
end

PTB.TYPE_FFA = 1
PTB.TYPE_TEST = 2
PTB.TYPE_TEAM = 3

PTB.STATE_PREROUND  = 1
PTB.STATE_ROUND     = 2
PTB.STATE_POSTROUND = 3

PTB.RoundTime = 15
PTB.NewRoundTime = 10
PTB.NewMatchTime = 30

PTB.ADDING_AI = false
PTB.TESTING = false

function PTB:Init()
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

		"Blink", "Night", "Speed", "SuperNight", "Toss"
	}
	PTB.Players = { }
	PTB.State = PTB.STATE_PREROUND
	PTB.Type = PTB.TYPE_FFA

	local time_txt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
	math.randomseed(tonumber(time_txt))

	ListenToGameEvent( 'dota_item_picked_up', Dynamic_Wrap( PTB, 'EventItemPickup' ),         PTB )
	ListenToGameEvent( 'dota_player_gained_level', Dynamic_Wrap( PTB, 'EventGainLevel' ),     PTB )
	ListenToGameEvent( 'game_rules_state_change', Dynamic_Wrap( PTB, 'EventStateChanged' ),   PTB )
	ListenToGameEvent( 'player_connect',      Dynamic_Wrap( PTB, 'EventPlayerConnected' ),    PTB )
	ListenToGameEvent( 'player_connect_full', Dynamic_Wrap( PTB, 'EventPlayerJoined' ),       PTB )
	ListenToGameEvent( 'player_team',         Dynamic_Wrap( PTB, 'EventPlayerJoinedTeam' ),   PTB )
	ListenToGameEvent( 'player_disconnect',   Dynamic_Wrap( PTB, 'EventPlayerDisconnected' ), PTB )
	ListenToGameEvent( 'player_reconnected',  Dynamic_Wrap( PTB, 'EventPlayerReconnected' ),  PTB )
	ListenToGameEvent( 'npc_spawned',         Dynamic_Wrap( PTB, 'EventNPCSpawned' ),         PTB )

	-- Game rules
	-- [[
	if PTB.TESTING then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 ) -- For dota_create_fake_clients
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	else
		Teams:Init()
	end
	--GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	--]]
	--Teams:Init()
	GameRules:SetCustomVictoryMessage( "Boom! Hahahaha" )
	--GameRules:SetHideKillMessageHeaders( true )

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetPreGameTime( 30 )
	GameRules:SetSameHeroSelectionEnabled( true )
	GameRules:SetFirstBloodActive( false )

	-- Gamemode settings
	local gamemode = GameRules:GetGameModeEntity()
	gamemode:SetAnnouncerDisabled( true )
	gamemode:SetBuybackEnabled( false )
	gamemode:SetCustomGameForceHero( "npc_dota_hero_techies" )
	--gamemode:SetCustomHeroMaxLevel( 0 )
	--gamemode:SetRecommendedItemsDisabled( true )

	-- Load modes
	print( "Loading modes:" )
	PTB.Modes = {}
	for _, name in pairs( PTB.ModeNames ) do
		PTB.Modes[name] = LoadModule( "Modes." .. name )
	end

	print( "Creating Da Bomb" )

	PTB.Bomb = Bomb()
	PTB.Bomb:Drop()
end


--[[
--   Round handling
--]]

function PTB:PickMode()
	if not PTB.LastMode then
		return PTB.Modes.Normal -- Always start on normal mode
	else
		-- Don't run the same mode two times in a row
		local newMode = PTB.LastMode
		repeat
			newMode = PTB.Modes[ PTB.ModeNames[ math.random( #PTB.ModeNames ) ] ]
		until newMode ~= PTB.LastMode
		print( "Old mode: " .. PTB.LastMode.Name .. ", New mode: " .. newMode.Name )

		return newMode
	end
end

function PTB:BeginRound( skip_time )
	PTB.State = PTB.STATE_PREROUND
	PTB.CurMode = PTB:PickMode()
	PTB.CurMode:Init()

	if not skip_time then
		PTB.Bomb:Drop()

		Say( nil, PTB.CurMode.Name .. " mode in " .. PTB.NewRoundTime .. " seconds", false )
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
		Say( nil, alive[ 1 ].Name .. " survived this one, next match in " .. PTB.NewMatchTime .. " seconds", false )
		alive[ 1 ].Score = alive[ 1 ].Score + 1

		if alive[ 1 ].Score >= 10 then
			Say( nil, alive[ 1 ].Name .. " has proven to be a cockroach by surviving ten matches!", false )
			GameRules:SetGameWinner( alive[ 1 ].Team )
		end
	elseif #alive == 0 then
		Say( nil, "You all died, that's pretty sad...", false )
		Say( nil, "Next match in " .. PTB.NewMatchTime .. " seconds.", false )
	end

	if #alive <= 1 then
		Timers:CreateTimer( ( PTB.NewMatchTime - PTB.NewRoundTime ), function() 
			--GameRules:SetHeroRespawnEnabled( true )

			for _,p in pairs( PlayerRegistry:GetDeadPlayers() ) do
				if p.State == Player.STATE_CONNECTED then
					--p.Hero:RespawnHero( false, false, false ) -- Why does this crash the map?
					p.HeroEntity:RespawnUnit()
				end
			end

			--GameRules:SetHeroRespawnEnabled( false )

			--GameRules:SetFirstBloodActive( false )
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


--[[-----------------------------------
-- Event handling
-------------------------------------]]

function PTB:EventGainLevel( event )
	print( "PTB:EventGainLevel" )
	PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		UserID = event.player
	} )

	if player then player:OnGainedLevel( event ) end
end

function PTB:EventItemPickup( event )
	print( "PTB:EventItemPickup" )
	PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		UserID = event.PlayerID
	} )

	if player then player:OnItemPickedup( event ) end
end

function PTB:EventNPCSpawned( event )
	print( "PTB::EventNPCSpawned" )
	PrintTable( event )

	local npc = EntIndexToHScript( event.entindex )

	if not IsValidEntity( npc) or not npc:IsHero() then return end

	local player = PlayerRegistry:GetPlayer( {
		Hero = npc
	} )

	if not player then
		player = PlayerRegistry:RegisterPlayer( Player.Create( npc:GetPlayerID() ) )
	end

	player:OnSpawned( event )
end

function PTB:EventPlayerConnected( event )
	print( "PTB:EventPlayerConnected" )
	PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		PlayerID = event.userid
	} )

	if player then player:OnConnected( event ) end
end

local playerCount = 0
function PTB:EventPlayerJoined( event )
	print( "PTB:EventPlayerJoined" )
	PrintTable( event )

	playerCount	= playerCount + 1

	local ply = EntIndexToHScript( event.index + 1 )
	local id = playerCount

	print( "Player #" .. id .. " connected." )

	if PTB.TESTING then
		ply:SetTeam( DOTA_TEAM_GOODGUYS )
	else
		ply:SetTeam( Teams.TeamIDs[ id ] )
	end

	PrecacheUnitByNameAsync( 'npc_dota_hero_techies', function() print( 'Techies precached!' ) end )

	if PTB.TESTING and not PTB.ADDING_AI then
		PTB.ADDING_AI = true
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
end

function PTB:EventPlayerDisconnected( event )
	print( "PTB:EventPlayerDisconnected" )
	PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		PlayerID = event.userid
	} )

	if player then player:OnDisconnected( event ) end
end

function PTB:EventPlayerJoinedTeam( event )
	print( "PTB:EventPlayerJoinedTeam" )
	PrintTable( event )

	local player = PlayerRegistry:GetPlayer( {
		PlayerID = event.userid
	} )

	if player then
		player:OnJoinedTeam( event )
	else
		PlayerRegistry:PrimeName( event.userid - 1, event.name )
	end
end

local firstFake = nil
function PTB:EventPlayersAllJoined()
	print( "PTB:EventPlayersAllJoined" )

	PTB.ADDING_AI = false
	if PTB.TESTING then
		if PTB.Type == PTB.TYPE_FFA then
			Teams:Init()
			CustomGameEventManager:Send_ServerToAllClients( "teams_changed", { } )

			for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
				PrintTable( p )
				p:SetTeam( Teams.TeamIDs[ p.ID ] )
			end
		end
	end

	for i = 0, PlayerResource:GetPlayerCount() do
		local ply = PlayerResource:GetPlayer( i )

		if IsValidEntity( ply ) then
			local hero = nil
			--if PlayerResource:HasSelectedHero( i ) and PlayerResource:GetSelectedHeroEntity( i ) then
				-- hero = PlayerResource:ReplaceHeroWith( i, 'npc_dota_hero_techies', 0, 0 )
			--else
			if not PlayerResource:IsFakeClient( i ) and not PlayerResource:GetSelectedHeroEntity( i ) then
				hero = CreateHeroForPlayer( 'npc_dota_hero_techies', ply )
			end
		end
	end
end

function PTB:EventStateChanged( event )
	print( "PTB:EventStateChanged" )
	--PrintTable( event )

	local state = GameRules:State_Get()
	print( "State: " .. state )

	if state == DOTA_GAMERULES_STATE_INIT then
		print( "  State: INIT" )
	elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		print( "  State: HERO_SELECTION" )
		Timers:CreateTimer( 2, function()
				if PlayerResource:HaveAllPlayersJoined() then
					PTB:EventPlayersAllJoined()
					return
				end
				return 1
		end )
		--[[
		local i = 0
		Timers:CreateTimer( 2, function()
			if i < PlayerResource:GetPlayerCount() then
				local ply = PlayerResource:GetPlayer( i )
				print( i .. ": " .. tostring( ply ) .. " (" .. ( IsValidEntity( ply ) and "is valid" or "is not valid" ) .. ")" )

				local hero = CreateHeroForPlayer( "npc_dota_hero_techies", ply )
				hero:SetControllableByPlayer( i, true )
				hero:SetPlayerID( i )

				i = i + 1
				return 2
			else
				return
			end
		end)
		--]]
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		print( "  State: PRE_GAME" )
		--[[
		if Convars:GetInt( "sv_cheats" ) == 1 then
			Timers:CreateTimer(4, function()
				if PTB.Type == PTB.TYPE_FFA then
					Teams:Init()
					CustomGameEventManager:Send_ServerToAllClients( "teams_changed", { } )

					for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
						p:SetTeam( Teams.TeamIDs[ p.ID ] )
					end
				end
			end )
		end
		--]]
		--[[
		local i = 0
		Timers:CreateTimer(4, function()
			if i < PlayerResource:GetPlayerCount() then
				local ply = PlayerResource:GetPlayer( i )
				print( i .. ": " .. tostring( ply ) .. " (" .. ( IsValidEntity( ply ) and "is valid" or "is not valid" ) .. ")" )

				if IsValidEntity( ply:GetAssignedHero() ) then
					print( "> Has hero" )
				else
					local hero = CreateHeroForPlayer( "npc_dota_hero_techies", ply )
				end

				i = i + 1
				return 2
			else
				return
			end
		end )
		--]]
		Say( nil, "First round starts in 30 seconds, get ready.", false )
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "  State: GAME_IN_PROGRESS" )
		PTB:BeginRound( true )
	end
end
