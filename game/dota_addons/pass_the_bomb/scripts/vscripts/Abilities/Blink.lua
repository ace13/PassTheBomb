function Blink( keys )
	local point = keys.target_points[ 1 ]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor( "blink_range", ( ability:GetLevel() - 1 ) )

	if difference:Length2D() > range then
		point = casterPos + ( point - casterPos ):Normalized() * range
	end

	FindClearSpaceForUnit( caster, point, true )
	ProjectileManager:ProjectileDodge( caster )
end

function EBlink( keys )
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local ability = keys.ability
	local range = ability:GetSpecialValueFor( "blink_range" )

	local point = casterPos + RandomVector( math.random( range ) )

	FindClearSpaceForUnit( caster, point, true )
	ProjectileManager:ProjectileDodge( caster )
end
