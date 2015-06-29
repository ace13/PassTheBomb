local Mode = {}
Mode.Name = "Super Blink"

function Mode:Init()
	print( "Blink:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Blink:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetAbilityLevel( "techies_blink", 3 )
	end
end

function Mode:Cleanup()
	print( "Blink:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetAbilityLevel( "techies_blink", 2 )
	end
end

return Mode