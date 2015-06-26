if not PTB then
	local PTBGamemode = class({})
	PTB = PTBGamemode()
	PTB.GamemodeClass = PTBGamemode
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

function PTB:Init()
	print( "Loading modules:" )
	LoadModule( "Bomb" )
	LoadModule( "Player" )
	LoadModule( "Teams" )
	LoadModule( "Timers" )

	PTB.Game = self
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

	ListenToGameEvent( 'dota_item_picked_up', Dynamic_Wrap( self, 'EventItemPickup' ),         self )
	ListenToGameEvent( 'dota_player_gained_level', Dynamic_Wrap( self, 'EventGainLevel' ),     self )
	ListenToGameEvent( 'game_rules_state_change', Dynamic_Wrap( self, 'EventStateChanged' ),   self )
	ListenToGameEvent( 'player_connect_full', Dynamic_Wrap( self, 'EventPlayerConnected' ),    self )
	ListenToGameEvent( 'player_team',         Dynamic_Wrap( self, 'EventPlayerJoinedTeam' ),   self )
	ListenToGameEvent( 'player_disconnect',   Dynamic_Wrap( self, 'EventPlayerDisconnected' ), self )
	ListenToGameEvent( 'player_reconnected',  Dynamic_Wrap( self, 'EventPlayerReconnected' ),  self )
	ListenToGameEvent( 'npc_spawned',         Dynamic_Wrap( self, 'EventNPCSpawned' ),         self )

	-- Game rules
	if ConVars:GetInt( "sv_cheats" ) == 1 then
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 ) -- For dota_create_fake_clients
	else
		GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 9 )
	end
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	GameRules:SetCustomVictoryMessage( "Boom! Hahahaha" )
	GameRules:SetHideKillMessageHeaders( true )

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetPreGameTime( 30 )
	GameRules:SetSameHeroSelectionEnabled( true )

	--GameRules:SetFirstBloodActive( true )

	-- Gamemode settings
	local gamemode = GameRules:GetGameModeEntity()
	gamemode:SetAnnouncerDisabled( true )
	gamemode:SetBuybackEnabled( false )
	gamemode:SetCustomGameForceHero( "npc_dota_hero_techies" )
	gamemode:SetCustomHeroMaxLevel( 0 )
	gamemode:SetRecommendedItemsDisabled( true )

	gamemode:SetThink( "OnTick", self )

	-- Load modes
	print( "Loading modes:" )
	PTB.Modes = {}
	for _, name in pairs( PTB.ModeNames ) do
		PTB.Modes[name] = LoadModule( "Modes." .. name )
	end

	print( "Creating Da Bomb" )

	PTB.Bomb = Bomb()
end


--[[-----------------------------------
-- Game mode handling
-------------------------------------]]

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

	if not skip_time then
		PTB.Bomb:Reset( true )
		CreateItemOnPositionSync( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), PTB.Bomb.Item )

		Say( nil, PTB.CurMode.Name .. " mode in " .. PTB.NewRoundTime .. " seconds", false )
	end

	Timers:CreateTimer( skip_time and 0 or PTB.NewRoundTime, function() 
		PTB.Bomb:Reset( true )
		PTB.State = PTB.STATE_ROUND

		PTB.CurMode.StartTime = GameRules:GetGameTime()
		PTB.CurMode:Init()

		local luckyGuy = PTB:FindRandomAlivePlayer()
		PTB.Bomb:Pass( luckyGuy.Hero )

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

	local alive = PTB:AlivePlayers()
	if #alive == 1 then
		Say( nil, alive[ 1 ].Name .. " wins this one, next match in " .. PTB.NewMatchTime .. " seconds", false )

		alive[ 1 ].Points = alive[ 1 ].Points + 1

		Timers:CreateTimer( ( PTB.NewMatchTime - PTB.NewRoundTime ), function() 
			GameRules:SetHeroRespawnEnabled( true )

			for _,p in pairs( PTB:DeadPlayers() ) do
				if p.State == Player.STATE_CONNECTED then
					--p.Hero:RespawnHero( false, false, false )
					p.Hero:RespawnUnit()
				end
			end

			GameRules:SetHeroRespawnEnabled( false )

			GameRules:SetFirstBloodActive( false )
			PTB:BeginRound()
		end )
	else
		Timers:CreateTimer( 1, function()
			PTB:BeginRound()
		end )
	end
end

function PTB:OnTick()
	local tick = GameRules:GetGameTime()
	local dt = tick - PTB.LastTick
	PTB.LastTick = tick

	if PTB.Bomb then PTB.Bomb:OnTick() end

	if PTB.CurMode and PTB.CurMode.OnTick then
		local ret = PTB.CurMode:OnTick()

		if ret ~= nil then
			return ret
		end
	end

	return 1
end


--[[-----------------------------------
-- Player handling
-------------------------------------]]

function PTB:AlivePlayers()
	local ret = { }

	for _,p in pairs( PTB.Players ) do
		if IsValidEntity( p.Hero ) and p.Hero:IsAlive() then
			ret[ #ret + 1 ] = p
		end
	end

	return ret
end

function PTB:DeadPlayers()
	local ret = { }

	for _,p in pairs( PTB.Players ) do
		if IsValidEntity( p.Hero ) and not p.Hero:IsAlive() then
			ret[ #ret + 1 ] = p
		end
	end

	return ret
end

function PTB:FindPlayer( search )
	if not search or type( search ) ~= "table" then return nil end
	if not search.State then search.State = Player.STATE_CONNECTED end

	for _,p in pairs( PTB.Players ) do
		if	( search.Entity   and p.Entity == search.Entity ) or
			( search.Index    and p.Index  == search.Index ) or
			( search.Name     and p.Name   == search.Name ) or
			( search.Player   and p.Entity == search.Player ) or
			( search.PlayerID and p.Entity and p.Entity:GetPlayerID() == search.PlayerID ) or
			( search.UserID   and p.UserID == search.UserID) then
			return p
		end
	end

	-- print( "Search failed to find a player, creating one.")
	return Player()
end

function PTB:FindRandomAlivePlayer()
	local ret = PTB:AlivePlayers()

	if #ret == 0 then return nil end

	return ret[ math.random(#ret) ]
end

function PTB:RegisterPlayer( player )
	if not PTB.Players then PTB.Players = {} end

	print( "Registering player #" .. player.ID )
	PTB.Players[ player.ID ] = player
end

function PTB:ReturningPlayer( player )
	player.State = Player.STATE_CONNECTED
end

function PTB:PlayerDisconnected( player )
	player.State = Player.STATE_DISCONNECTED
end

function PTB:ExplodePlayer( player, ability, caster )
	local target = nil
	if player.Hero then
		target = player.Hero
	else
		target = player
	end

	if not IsValidEntity( target ) then return end

	print( target.Player.Name .. " goes asplodey" )

	local ability = target:FindAbilityByName( "techies_explode" )
	ability:SetLevel( 1 )
	ability:CastAbility()
	ability:SetLevel( 0 )

	target:Kill( ability, caster )
end


--[[-----------------------------------
-- Event handling
-------------------------------------]]

function PTB:EventGainLevel( event )
	print( "PTB:EventGainLevel" )
	-- DeepPrintTable( event )

	local p = PTB:FindPlayer( { UserID = event.player } )

	p.Hero:SetAbilityPoints( 0 )
end

function PTB:EventItemPickup( event )
	print( "PTB:EventItemPickup" )
	--DeepPrintTable( event )

	local item = EntIndexToHScript( event.ItemEntityIndex )
	local hero = EntIndexToHScript( event.HeroEntityIndex )

	if item == PTB.Bomb.Item then
		print( hero.Player.Name .. " picked up the bomb, the idiot" )

		hero:RemoveItem( PTB.Bomb.Item )
		PTB.Bomb:Pass( hero )
	end
end

function PTB:EventNPCSpawned( event )
	print( "PTB::EventNPCSpawned" )
	--DeepPrintTable( event )

	local npc = EntIndexToHScript( event.entindex )

	if not npc:IsHero() then return end

	local p = PTB:FindPlayer( { UserID = npc:GetPlayerID() + 1 } )

	p:OnSpawn( event )
end

function PTB:EventPlayerConnected( event )
	print( "PTB:EventPlayerConnected" )
	--DeepPrintTable( event )

	local p = PTB:FindPlayer( { UserID = event.userid } )

	p:OnConnect( event )
end

function PTB:EventPlayerDisconnected( event )
	print( "PTB:EventPlayerDisconnected" )
	DeepPrintTable( event )

	local p = PTB:FindPlayer( { UserID = event.userid } )

	p:OnDisconnect( event )
end

function PTB:EventPlayerJoinedTeam( event )
	print( "PTB:EventPlayerJoinedTeam" )
	--DeepPrintTable( event )

	local p = PTB:FindPlayer( { UserID = event.userid } )

	p:OnJoinTeam( event )
end

function PTB:EventStateChanged( event )
	print( "PTB:EventStateChanged" )
	local state = GameRules:State_Get()
	--print( state )

	if state == DOTA_GAMERULES_STATE_INIT then
	elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		Timers:CreateTimer(4, function()
			if PTB.Type == PTB.TYPE_FFA then
				Teams:Init()
				CustomGameEventManager:Send_ServerToAllClients( "teams_changed", { } )

				for _, p in pairs( PTB.Players ) do
					p:SetTeam( Teams.TeamIDs[ p.ID + 1 ] )
				end
			end
		end )


		Say( nil, "First round starts in 30 seconds, get ready.", false )
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		

		PTB:BeginRound( true )
	end
end
