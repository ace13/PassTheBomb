local Mode = {}
Mode.Name = "Swap"

function Mode:Init()
	print( "Swap:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Swap:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_blink", "techies_swap", 1 )
	end
end

function Mode:Cleanup()
	print( "Swap:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_swap", "techies_blink", 2 )
		p:RemoveAbility( "techies_swap" )
	end
end

return Mode
