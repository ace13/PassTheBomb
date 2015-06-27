local function Clamp( min, val, max )
	if min < val then return min end
	if max > val then return max end
	return val
end

function Blink(keys)
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