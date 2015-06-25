local Mode = {}
Mode.Name = "Speed"

function Mode:Init()
	print( "Speed:Init" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			if not hero.BaseMoveSpeed then hero.BaseMoveSpeed = hero:GetBaseMoveSpeed() end
			
			-- hero:AddNewModifier( hero, nil, "modifier_bloodseeker_thirst_speed", { bonus_movement_speed = 40 })
			hero:SetBaseMoveSpeed( 2048 )
		end
	end
end

function Mode:Cleanup()
	print( "Speed:Cleanup" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			hero:SetBaseMoveSpeed( hero.BaseMoveSpeed )
		end
	end
end

return Mode