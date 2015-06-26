function PassTheBomb( keys )
	--DeepPrintTable( keys )
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:EndCooldown()
	PTB.Bomb:Pass( target, caster )

end

function Refresh( keys )
	local ability = keys.ability

	ability:EndCooldown()
end