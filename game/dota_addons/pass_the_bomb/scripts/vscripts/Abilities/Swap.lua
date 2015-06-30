function Swap( keys )
	local caster = keys.caster
	local target = keys.target

	local caster_pos = caster:GetAbsOrigin()
	local target_pos = target:GetAbsOrigin()

	caster:SetAbsOrigin( target_pos )
	target:SetAbsOrigin( caster_pos )

	target:Stop()
end
