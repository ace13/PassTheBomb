if not PTB then
	local PTBGamemode = class({})
	PTB = PTBGamemode()
	PTB.GamemodeClass = PTBGamemode
end

PTB.STATE_PREROUND  = 1
PTB.STATE_ROUND     = 2
PTB.STATE_POSTROUND = 3

function PTB:Init()
	print( "Loading modules:" )
	LoadModule( "Bomb" )
	LoadModule( "Player" )


	PTB.Game = self
	PTB.LastTick = GameRules:GetGameTime()
	PTB.ModeNames = {
		"Normal",

		"Blink", "Night", "Speed", "SuperNight", "Toss"
	}
	PTB.Players = { }
	PTB.State = PTB.STATE_PREROUND

	ListenToGameEvent( 'dota_item_picked_up', Dynamic_Wrap( self, 'EventItemPickup' ),         self )
	ListenToGameEvent( 'player_connect_full', Dynamic_Wrap( self, 'EventPlayerConnected' ),    self )
	ListenToGameEvent( 'player_team',         Dynamic_Wrap( self, 'EventPlayerJoinedTeam' ),   self )
	ListenToGameEvent( 'player_disconnect',   Dynamic_Wrap( self, 'EventPlayerDisconnected' ), self )
	ListenToGameEvent( 'player_reconnected',  Dynamic_Wrap( self, 'EventPlayerReconnected' ),  self )
	ListenToGameEvent( 'npc_spawned',         Dynamic_Wrap( self, 'EventNPCSpawned' ),         self )

	-- Game rules
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	GameRules:SetCustomVictoryMessage( "Boom! Hahahaha" )

	GameRules:SetGoldPerTick( 0 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetPreGameTime( 30 )
	GameRules:SetSameHeroSelectionEnabled( true )

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

	Timers:CreateTimer(20, function()
		Say( nil, "First round in 30s", false )
		PTB:BeginRound()
	end )
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

function PTB:BeginRound()
	PTB.State = PTB.STATE_PREROUND
	PTB.CurMode = PTB:PickMode()

	PTB.Bomb:Reset()
	CreateItemOnPositionSync( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), PTB.Bomb.Item )

	Say( nil, PTB.CurMode.Name .. " mode in 10s", false )

	Timers:CreateTimer( 10, function() 
		PTB.Bomb:Take()
		PTB.State = PTB.STATE_ROUND

		local luckyGuy = PTB.Players[ math.random( #PTB.Players) ]
		PTB.Bomb:Give( luckyGuy )
		Say( nil, luckyGuy.Name .. " is the lucky guy.", false)

		PTB.CurMode.StartTime = GameRules:GetGameTime()
		PTB.CurMode:Init()
	end )
end

function PTB:EndRound()
	if not PTB.CurMode then return end

	PTB.State = PTB.STATE_POSTROUND
	local mode = PTB.CurMode
	PTB.CurMode = nil

	mode:Cleanup()

	PTB.LastMode = mode

	Timers:CreateTimer( 10, function()
		Say( nil, "10s until next round", false )
		PTB:BeginRound()
	end )
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

	print( "Search failed to find a player, creating one.")
	return Player()
end

function PTB:RegisterPlayer( player )
	if not PTB.Players then PTB.Players = {} end

	PTB.Players[ #PTB.Players + 1 ] = player
end

function PTB:ReturningPlayer( player )
	player.State = Player.STATE_CONNECTED
end

function PTB:PlayerDisconnect( player )
	player.State = Player.STATE_DISCONNECTED
end

function PTB:ExplodePlayer( player )
	local target = nil
	if player.Hero then
		target = player.Hero
	else
		target = player
	end

	if not IsValidEntity( target ) then return end

	print( target.Player.Name .. " goes asplodey" )
end


--[[-----------------------------------
-- Event handling
-------------------------------------]]

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
