Teams = Teams or { }

function Teams:Init()
	for i=DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		Teams[ i ] = nil
	end

	AddTeam( DOTA_TEAM_GOODGUYS, "Team 1",  Vector(  46, 106, 230 ) )
	AddTeam( DOTA_TEAM_BADGUYS,  "Team 2",  Vector(  93, 230, 173 ) )
	AddTeam( DOTA_TEAM_CUSTOM_1, "Team 3",  Vector( 173,   0, 173 ) )
	AddTeam( DOTA_TEAM_CUSTOM_2, "Team 4",  Vector( 220, 217,  10 ) )
	AddTeam( DOTA_TEAM_CUSTOM_3, "Team 5",  Vector( 230,  98,   0 ) )
	AddTeam( DOTA_TEAM_CUSTOM_4, "Team 6",  Vector( 230, 122, 176 ) )
	AddTeam( DOTA_TEAM_CUSTOM_5, "Team 7",  Vector( 146, 164,  64 ) )
	AddTeam( DOTA_TEAM_CUSTOM_6, "Team 8",  Vector(  92, 197, 224 ) )
	AddTeam( DOTA_TEAM_CUSTOM_7, "Team 9",  Vector(   0, 119,  31 ) )
	AddTeam( DOTA_TEAM_CUSTOM_8, "Team 10", Vector( 149,  96,   0 ) )

	for t,v in pairs( Teams ) do
		GameRules:SetCustomGameTeamMaxPlayers( t, 1 )
		SetTeamCustomHealthbarColor( t, v.Color[ 1 ], v.Color[ 2 ], v.Color[ 3 ] )
	end
end

function Teams:AddTeam( teamID, name, color, limit )
	Teams[ teamID ] = {
		Color = color,
		ID = teamID,
		Limit = limit or 1,
		Name = name,
	}
end

function Teams:FindFirstFreeTeam()
	for _, v in pairs( Teams ) do
		local players = PlayerResource:GetPlayerCountForTeam( v.ID )
		if players < v.Limit then
			return v
		end
	end
end

return Teams
