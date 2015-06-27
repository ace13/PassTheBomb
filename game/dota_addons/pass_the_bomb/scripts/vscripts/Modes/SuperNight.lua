local Mode = {}
Mode.Name = "Darkest of Nights"

function Mode:Init()
	print( "SuperNight:Init" )
	GameRules:SetTimeOfDay( 0.76 )

	self.Listener = ListenToGameEvent( "ptb_bomb_pass", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Start()
	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetVisionMod( 0.5, VISION_NIGHT )
	end
end

function Mode:Cleanup()
	print( "SuperNight:Cleanup" )

	StopListeningToGameEvent( self.Listener )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetVisionMod( 1, VISION_NIGHT )
	end
end

function Mode:BombPassed( event )
	local from = event.old_carrier
	local to   = event.new_carrier
	local bomb = event.bomb

	if from then
		from:SetSpeed( from:GetBaseSpeed() )
		from:SetVisionMod( 0.5, VISION_NIGHT )
	end
	
	to:SetSpeed( 2048 )
	to:SetVisionMod( 0.3, VISION_NIGHT )
end

return Mode