require( "Util" )
require( "PTB" )

-- Precache things that need to be precached
function Precache( context )
	-- Explosions
	-- PrecacheResource( "soundfile", "*.vsndevts", context )
	-- PrecacheResource( "particle", "*.vpcf", context )
end

-- Create the game mode when we activate
function Activate()
	print( "Pass The Bomb running, here there be dragons" )

	PTB:Init()

	Convars:RegisterCommand( "ptb_next", function(...)
			PTB:End()
			PTB:Begin()
		end, "Next round", 0 )
end