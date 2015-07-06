local Mode = {}
Mode.Name = "Supermench"

function Mode:Init()
	print( "Super:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Super:Start" )

	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetAbilityLevel( "techies_blink", 3 )
		p:SetSpeed( 750 )
	end
end

function Mode:Cleanup()
	print( "Super:Cleanup" )

	StopListeningToGameEvent( self.Listener )
	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetAbilityLevel( "techies_blink", 2 )
		p:SetSpeed( p.GetBaseSpeed() )
	end
end

function Mode:BombPassed( event )
	local to = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )

	to:SetAbilityLevel( "techies_pass_the_bomb", 3 )
end

return Mode
