local Mode = {}
Mode.Name = "Hook"

function Mode:Init()
	print( "Hook:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Hook:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_blink", "techies_hook", 1 )
	end
end

function Mode:Cleanup()
	print( "Hook:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_hook", "techies_blink", 2 )
		p:RemoveAbility( "techies_hook" )
	end
end

return Mode
