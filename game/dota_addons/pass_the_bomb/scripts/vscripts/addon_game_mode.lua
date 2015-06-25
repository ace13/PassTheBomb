require( "PTB.lua" )

if PTBGamemode == nil then
	PTBGamemode = class({})
end

-- Precache things that need to be precached
function Precache( context )
	-- Explosions
	-- PrecacheResource( "soundfile", "*.vsndevts", context )
	-- PrecacheResource( "particle", "*.vpcf", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.Gamemode = PTBGamemode()
	GameRules.Gamemode:InitGameMode()
	PTB.Init()
end

function PTBGamemode:InitGameMode()
	print( "PTBGamemode:InitGameMode()" )

	-- Game rules
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 10 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	GameRules:SetCustomGameVictoryMessage( "You're winner" )

	GameRules:SetGoldPerTick(0)
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetSameHeroSelectionEnabled( true )

	-- Gamemode settings
	local gamemode = GameRules:GetGameModeEntity()
	gamemode:SetAnnouncerDisabled( true )
	gamemode:SetBuybackEnabled( false )
	gamemode:SetCustomGameForceHero( "npc_dota_hero_techies" )
	gamemode:SetCustomHeroMaxLevel( 0 )
	gamemode:SetRecommendedItemsDisabled( true )
end
