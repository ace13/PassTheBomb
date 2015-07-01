local Mode = {}
Mode.Name = "Storm Hammer"

function Mode:Init()
	print( "Hammer:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Hammer:Start" )

	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Cleanup()
	print( "Hammer:Cleanup" )

	StopListeningToGameEvent( self.Listener )
end

function Mode:BombPassed( event )
	local from = PlayerRegistry:GetPlayer( { UserID = event.old_carrier } )
	if not from then return end

	local to = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )
	to.HeroEntity:AddNewModifier( from.HeroEntity, from:GetAbility( "techies_pass_the_bomb" ), "modifier_stunned", { Duration = 0.5 } )
end

return Mode
