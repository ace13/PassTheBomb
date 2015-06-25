local Mode = {}
Mode.Name = "Normal"

function Mode:Init()
	print( "Normal:Init" )
end

function Mode:Cleanup()
	print( "Normal:Cleanup" )
end

function Mode:OnTick()
	GameRules:SetTimeOfDay( 0.5 )
end

return Mode