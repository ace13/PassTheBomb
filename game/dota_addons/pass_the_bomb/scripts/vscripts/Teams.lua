Teams = {}

Teams.Colors = {
	nil,                   -- unused teams
	Vector(46, 106, 230),  -- Player 1
	Vector(93, 230, 173),  -- Player 2
	nil, nil,              -- unused teams
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
-- For some reason, lots of things break when not all players change teams.
-- So we disable the radiant team after team selection. Not really a fix though...
	DOTA_TEAM_GOODGUYS,
	DOTA_TEAM_BADGUYS,
	DOTA_TEAM_CUSTOM_1,
	DOTA_TEAM_CUSTOM_2, 
	DOTA_TEAM_CUSTOM_3, 
	DOTA_TEAM_CUSTOM_4, 
	DOTA_TEAM_CUSTOM_5,
	DOTA_TEAM_CUSTOM_6,
	DOTA_TEAM_CUSTOM_7,
	DOTA_TEAM_CUSTOM_8,
}

Teams.Inited = false

function Teams:Init()
	if Teams.Inited then return end
	Teams.Inited = true

	for _,t in pairs( Teams.TeamIDs ) do
		GameRules:SetCustomGameTeamMaxPlayers( t, 1 )
		SetTeamCustomHealthbarColor( t, Teams.Colors[ t ][ 1 ], Teams.Colors[ t ][ 2 ], Teams.Colors[ t ][ 3 ] )
	end
end
