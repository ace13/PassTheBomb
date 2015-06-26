Teams = {}

Teams.Colors = {
	nil, nil,              -- 0, 1, unused teams
	Vector(46, 106, 230),  -- Player 1
	Vector(93, 230, 173),  -- Player 2
	nil, nil,              -- 4, 5, unused teams
	Vector(173, 0, 173),   -- Player 3
	Vector(220, 217, 10),  -- Player 4
	Vector(230, 98, 0),    -- Player 5
	Vector(230, 122, 176), -- Player 6
	Vector(146, 164, 64),  -- Player 7
	Vector(92, 197, 224),  -- Player 8
	Vector(0, 119, 31),    -- Player 9
	Vector(149, 96, 0)     -- Player 10
}

Teams.TeamIDs = {
	2, 3, 6, 7, 8, 9, 10, 11, 12, 13
}

Teams.Inited = false

function Teams:Init()
	if Teams.Inited then return end
	Teams.Inited = true

	for i = 0, DOTA_TEAM_COUNT - 1 do
		if Teams.Colors[ i + 1 ] then
			GameRules:SetCustomGameTeamMaxPlayers( i, 1 )
			SetTeamCustomHealthbarColor( i, Teams.Colors[ i + 1 ][ 1 ], Teams.Colors[ i + 1 ][ 2 ], Teams.Colors[ i + 1 ][ 3 ] )
		end
	end
end
