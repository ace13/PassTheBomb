require( "Util" )
require( "PTB" )
require( "Teams" )


-- Precache things that need to be precached
function Precache( context )
	-- Explosions
	-- PrecacheResource( "soundfile", "*.vsndevts", context )
	-- PrecacheResource( "particle", "*.vpcf", context )

	PrecacheUnitByNameSync( "npc_dota_hero_techies", context )
	--PrecacheResource( "model", "models/heroes/techies/fx_techies_remotebomb.vmdl", context )
end

-- Create the game mode when we activate
function Activate()
	print( "Pass The Bomb running, here there be dragons" )

	--Teams:Init()
	PTB:Init()

	Convars:RegisterCommand( "ptb_next", function(...)
		PTB:BeginRound()
	end, "Next round", 0 )

	Convars:RegisterCommand( "ptb_test", function(...)
		PlayerRegistry:GetPlayer().Score = 10
	end, "Test, go", 0 )

	Convars:RegisterCommand( "ptb_fast", function(...)
		PTB.RoundTime = 5
		PTB.NewRoundTime = 5
		PTB.NewMatchTime = 10
		GameRules:SetPreGameTime( 10 )

		Say( nil, "Fast rounds enabled, prepare to APM", false )
	end, "Faster rounds", 0 )

	Convars:RegisterCommand( "ptb_sanic", function(...)
		PTB.RoundTime = 1
		PTB.NewRoundTime = 1
		PTB.NewMatchTime = 5
		GameRules:SetPreGameTime( 5 )

		Say( nil, "Sanic mode: ACTIVE! (May god have mercy on your souls)", false )
	end, "Gotta go fast", 0 )
end