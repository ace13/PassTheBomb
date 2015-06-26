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

	local carrier = PTB.Bomb:GetCarrier()

	if IsValidEntity( carrier ) then
		carrier:SetNightTimeVisionRange( carrier.BaseNightTimeVision * 0.25 )

		if not carrier.BaseMoveSpeed then carrier.BaseMoveSpeed = carrier:GetBaseMoveSpeed() end
		carrier:SetBaseMoveSpeed( 2048 )
	end

	PTB.Bomb:AddOnPass( "SuperNight", function( from, to, bomb )
		print( "Bomb passed from " .. (from and from.Player.Name or "nobody") .. " to " .. to.Player.Name )

		if IsValidEntity( from ) then
			from:SetNightTimeVisionRange( from.BaseNightTimeVision )
			from:SetBaseMoveSpeed( from.BaseMoveSpeed )
		end

		if IsValidEntity( to ) then
			to:SetNightTimeVisionRange( to.BaseNightTimeVision * 0.25 )
			if not to.BaseMoveSpeed then to.BaseMoveSpeed = to:GetBaseMoveSpeed() end
			to:SetBaseMoveSpeed( 2048 )
		end
	end )
end

function Mode:Cleanup()
	print( "SuperNight:Cleanup" )

	PTB.Bomb:RemoveOnPass( "SuperNight" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			hero:SetNightTimeVisionRange( hero.BaseNightTimeVision )

			if hero.BaseMoveSpeed then
				hero:SetBaseMoveSpeed( hero.BaseMoveSpeed )
			end
		end
	end

	GameRules:SetTimeOfDay( 0.26 )
end

function Mode:OnTick()
	GameRules:SetTimeOfDay( 0 )
end

return Mode