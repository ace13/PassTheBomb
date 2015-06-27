local Mode = {}
Mode.Name = "Speed"

function Mode:Init()
	print( "Speed:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Speed:Start" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetSpeed( 750 )
	end
end

function Mode:Cleanup()
	print( "Speed:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetSpeed( p:GetBaseSpeed() )
	end
end

return Mode