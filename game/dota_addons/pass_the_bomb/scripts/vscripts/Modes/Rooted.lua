local Mode = {}
Mode.Name = "Rooted"

function Mode:Init()
	print( "Rooted:Init" )
	
	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:Start()
	print( "Rooted:Start" )

	Entities:FindByName( nil, "bomb_spawn" ):EmitSound( "Hero_Treant.Overgrowth.Cast" )
	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p.HeroEntity:AddNewModifier(
			p.HeroEntity,
			nil,
			"modifier_rooted",
			{ duration = 10000 }
		)
	end
end

function Mode:Cleanup()
	print( "Rooted:Cleanup" )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p.HeroEntity:RemoveModifierByName( "modifier_rooted" )
	end
end

return Mode