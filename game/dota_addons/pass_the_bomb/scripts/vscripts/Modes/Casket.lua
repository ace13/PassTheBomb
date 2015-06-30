local Mode = {}
Mode.Name = "Casket"

function Mode:Init()
	print( "Casket:Init" )

	GameRules:SetTimeOfDay( 0.26 )

	if RollPercentage( 50 ) then
		self.SuperToss = true
		self.Name = "Look At It Go"
	else
		self.SuperToss = false
		self.Name = "Casket"
	end
end

function Mode:Start()
	print( "Casket:Start" )

	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Cleanup()
	print( "Casket:Cleanup" )

	StopListeningToGameEvent( self.Listener )
end

function Mode:BombPassed( event )
	if event.old_carrier == -1 then return end
	local to = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )

	local ability = to:GetAbility( "techies_pass_the_bomb" )

	if self.SuperToss then
		ability:SetLevel( 2 )
	end

	local pos = to.HeroEntity:GetAbsOrigin()
	local range = ability:GetLevelSpecialValueFor( "cast_range", ability:GetLevel() - 1 )

	local units = FindUnitsInRadius(
		to.Team,
		pos,
		nil,
		range,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER,
		false
	)

	if not units or #units < 1 then return end

	local target = units[ math.random( #units ) ]

	local throw_speed = ability:GetLevelSpecialValueFor( "throw_speed", ability:GetLevel() - 1 )

	local info = {
		Target = target,
		Source = to.HeroEntity,
		Ability = ability,
		EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
		bDogeable = true,
		bProvidesVision = false,
		iMoveSpeed = throw_speed,
		iVisionRadius = 0,
		iVisionTeamNumber = 0,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
	}

	ProjectileManager:CreateTrackingProjectile( info )
	to.HeroEntity:EmitSound( "Hero_Techies.RemoteMine.Toss" )
	ability:StartCooldown( 10000 )
end

return Mode
