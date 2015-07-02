function Tick( keys )
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()
	
	MinimapEvent( -1, caster, pos[ 1 ], pos[ 2 ], DOTA_MINIMAP_EVENT_HINT_LOCATION, 0 )
end
