local Mode = {}
Mode.Name = "Night"

function Mode:Init()
	print( "Night:Init" )
	
	GameRules:SetTimeOfDay( 0.76 )
	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Start()
	print( "Night:Start" )
end

function Mode:Cleanup()
	print( "Night:Cleanup" )

	StopListeningToGameEvent( self.Listener )
end

function Mode:BombPassed( event )
	if event.old_carrier == -1 then return end
	local to = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )

	to:SetVisionMod( 0.6 )
	Timers:CreateTimer( 0.5, function() 
		to:SetVisionMod( 1, VISION_NIGHT )
	end )
end

return Mode