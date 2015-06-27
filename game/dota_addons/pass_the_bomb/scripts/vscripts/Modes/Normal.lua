local Mode = {}
Mode.Name = "Normal"

function Mode:Init()
	print( "Normal:Init" )

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Normal:Start" )
end

function Mode:Cleanup()
	print( "Normal:Cleanup" )
end

return Mode