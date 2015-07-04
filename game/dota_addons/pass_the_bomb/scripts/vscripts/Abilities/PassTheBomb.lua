function PassTheBomb( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	ability:EndCooldown()
	PTB.Bomb:Pass( target.Player, caster.Player )
end

function Refresh( keys )
	local ability = keys.ability
	local caster = keys.caster

	ability:EndCooldown()
	ability:StartCooldown( 1 )

	Messages:Popup( {
		Target = caster,
		Type = "crit",
		PreSymbol = SYMBOL_PRE_EVADE,
		Color = Vector( 255, 255, 0 ),
		Duration = 2
	} )
	
	if not caster.Player then return end

	local bomb = caster.Player:GetItem( "item_bomb" )
	local time = bomb:TimeLeft()

	if time <= 1 then
		-- Humiliation? Last second save?
		Messages:Announce( "impressive", { Reason = nil, Message = "did a last second dodge" } )
	end
end
