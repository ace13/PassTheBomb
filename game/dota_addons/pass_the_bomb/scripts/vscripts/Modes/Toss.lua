local Mode = {}
Mode.Name = "Super Toss"

function Mode:Init()
	print( "Toss:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Toss:Start" )

	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Cleanup()
	print( "Toss:Cleanup" )

	StopListeningToGameEvent( self.Listener )
end

function Mode:BombPassed( event )
	local to = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )

	to:SetAbilityLevel( "techies_pass_the_bomb", 3 )
end

return Mode
