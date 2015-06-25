local Mode = {}
Mode.Name = "Darkest of Nights"

function Mode:Init()
	print( "SuperNight:Init" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			if not hero.BaseNightTimeVision then hero.BaseNightTimeVision = hero:GetBaseNightTimeVisionRange() end

			hero:SetNightTimeVisionRange( hero.BaseNightTimeVision * 0.5 )
		end
	end

	local carrier = PTB.Bomb:Carrier()

	if IsValidEntity( carrier ) then
		carrier:SetNightTimeVisionRange( carrier.BaseNightTimeVision * 0.25 )
		carrier:SetBaseMoveSpeed( 2048 )
	end
end

function Mode:Cleanup()
	print( "SuperNight:Cleanup" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			hero:SetNightTimeVisionRange( hero.BaseNightTimeVision )

			if not hero.BaseMoveSpeed then hero.BaseMoveSpeed = hero:GetBaseMoveSpeed() end
			hero:SetBaseMoveSpeed( hero.BaseMoveSpeed )
		end
	end

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:OnTick()
	GameRules:SetTimeOfDay( 0 )
end

return Mode