local Mode = {}
Mode.Name = "Super Toss"

function Mode:Init()
	print( "Toss:Init" )

	self.Listener = ListenToGameEvent( "ptb_bomb_pass", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Start()
	print( "Toss:Start" )
end

function Mode:Cleanup()
	print( "Toss:Cleanup" )

	StopListeningToGameEvent( self.Listener )
end

function Mode:BombPassed( event )
	local to = event.new_carrier

	to:SetAbilityLevel( "techies_pass_the_bomb", 2 )
end

return Mode