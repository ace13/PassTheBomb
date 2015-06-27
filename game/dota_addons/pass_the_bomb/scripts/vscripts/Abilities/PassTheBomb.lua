function PassTheBomb( keys )
	--DeepPrintTable( keys )
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:EndCooldown()
	PTB.Bomb:Pass( target.Player, caster.Player )

end

function Refresh( keys )
	--DeepPrintTable( keys )

	local ability = keys.ability

	ability:EndCooldown()
	ability:StartCooldown( 2 )
end