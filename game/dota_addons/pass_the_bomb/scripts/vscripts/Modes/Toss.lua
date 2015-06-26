local Mode = {}
Mode.Name = "Super Toss"

function Mode:Init()
	print( "Toss:Init" )

	PTB.Bomb:AddOnPass( "SuperToss", function( from, to )
		to:FindAbilityByName( "techies_pass_the_bomb" ):SetLevel( 2 )
	end )
end

function Mode:Cleanup()
	print( "Toss:Cleanup" )

	PTB.Bomb:RemoveOnPass( "SuperToss" )
end

function Mode:OnTick()
	GameRules:SetTimeOfDay( 0.5 )
end

return Mode