local Mode = {}
Mode.Name = "Night"

function Mode:Init()
	print( "Night:Init" )
end

function Mode:Cleanup()
	print( "Night:Cleanup" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:OnTick()
	GameRules:SetTimeOfDay( 0 )
end

return Mode