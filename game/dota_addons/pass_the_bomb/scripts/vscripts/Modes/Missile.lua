local Mode = {}
Mode.Name = "Missile"

function Mode:Init()
	print( "Missile:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Missile:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_pass_the_bomb", "techies_missile", 1 )
	end
end

function Mode:Cleanup()
	print( "Missile:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_missile", "techies_pass_the_bomb", 2 )
		p:RemoveAbility( "techies_missile" )
	end
end

return Mode
