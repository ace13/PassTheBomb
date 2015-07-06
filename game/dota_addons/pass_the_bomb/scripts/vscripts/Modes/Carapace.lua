local Mode = {}
Mode.Name = "Carapace"

function Mode:Init()
	print( "Carapace:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Carapace:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_blink", "techies_carapace", 1 )
		p:SetAbilityLevel( "techies_pass_the_bomb", 1 )
	end
end

function Mode:Cleanup()
	print( "Carapace:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_carapace", "techies_blink", 2 )
		p:RemoveAbility( "techies_carapace" )
		p:SetAbilityLevel( "techies_pass_the_bomb", 2 )
	end
end

return Mode
