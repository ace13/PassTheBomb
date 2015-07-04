local Mode = {}
Mode.Name = "Emergency Blink"

function Mode:Init()
	print( "EBlink:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "EBlink:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_blink", "techies_eblink", 1 )
	end
end

function Mode:Cleanup()
	print( "EBlink:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SwapAbility( "techies_eblink", "techies_blink", 2 )
		p:RemoveAbility( "techies_eblink" )
	end
end

return Mode
