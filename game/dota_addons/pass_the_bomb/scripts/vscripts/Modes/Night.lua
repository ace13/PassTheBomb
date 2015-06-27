local Mode = {}
Mode.Name = "Night"

function Mode:Init()
	print( "Night:Init" )
	
	GameRules:SetTimeOfDay( 0.76 )
end

function Mode:Start()
	print( "Night:Start" )
end

function Mode:Cleanup()
	print( "Night:Cleanup" )
end

return Mode