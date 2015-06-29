function PassTheBomb( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:EndCooldown()
	PTB.Bomb:Pass( target.Player, caster.Player )

end

function Refresh( keys )
	local ability = keys.ability
	-- PrintTable( keys )

	ability:EndCooldown()
	ability:StartCooldown( 2 )

	ShowPopup( {
		Target = keys.caster.Player.HeroEntity,
		Type = "crit",
		PreSymbol = POPUP_SYMBOL_PRE_EVADE,
		Color = Vector( 255, 255, 0 ),
		Duration = 2
	} )
end