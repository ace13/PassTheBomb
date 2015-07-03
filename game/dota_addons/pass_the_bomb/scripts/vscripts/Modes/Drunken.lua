local Mode = {}
Mode.Name = "Drunken"

function Mode:Init()
	print( "Drunken:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Drunken:Start" )

	ScreenShake(
		Vector( 0, 0, 0 ),
		100,
		1,
		1,
		10,
		SHAKE_START,
		true
	)
end

function Mode:Cleanup()
	print( "Drunken:Cleanup" )

	--Timers:RemoveTimer( self.Timer )
	ScreenShake( Vector( 0, 0, 0 ), 0, 0, 0, 0, SHAKE_STOP, true )
end

return Mode
