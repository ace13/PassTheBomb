Teams = Teams or { }

function Teams:Init()
	if #Teams > 0 then return end

	_AddTeam( DOTA_TEAM_GOODGUYS, "Team 1",  Vector(  46, 106, 230 ) )
	_AddTeam( DOTA_TEAM_BADGUYS,  "Team 2",  Vector(  93, 230, 173 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_1, "Team 3",  Vector( 173,   0, 173 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_2, "Team 4",  Vector( 220, 217,  10 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_3, "Team 5",  Vector( 230,  98,   0 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_4, "Team 6",  Vector( 230, 122, 176 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_5, "Team 7",  Vector( 146, 164,  64 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_6, "Team 8",  Vector(  92, 197, 224 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_7, "Team 9",  Vector(   0, 119,  31 ) )
	_AddTeam( DOTA_TEAM_CUSTOM_8, "Team 10", Vector( 149,  96,   0 ) )

	for t,v in pairs( Teams ) do
		GameRules:SetCustomGameTeamMaxPlayers( t, 1 )
		SetTeamCustomHealthbarColor( t, v.Color[ 1 ], v.Color[ 2 ], v.Color[ 3 ] )
	end
end

function Teams:_AddTeam( teamID, name, color )
	Teams[ teamID ] = {
		Name = name,
		Color = color
	}
end

return Teams
