local Mode = {}
Mode.Name = "Casket"

function Mode:Init()
	print( "Casket:Init" )

	GameRules:SetTimeOfDay( 0.26 )
	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
end

function Mode:Start()
	print( "Casket:Start" )
end

function Mode:Cleanup()
	print( "Casket:Cleanup" )

	StopListeningToGameEvent( self.Listener )
end

function Mode:BombPassed( event )
	if event.old_carrier == -1 then return end
	local to = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )

	local ability = to:GetAbility( "techies_pass_the_bomb" )
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

	if #units < 1 then return end

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
	to.HeroEntity:EmitSound( "Hero_Techies.RemoteMine.Toss" )
	ProjectileManager:CreateTrackingProjectile( info )
end

return Mode