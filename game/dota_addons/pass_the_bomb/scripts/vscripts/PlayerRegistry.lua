if not PlayerRegistry then
	PlayerRegistry = { }
	PlayerRegistry.__index = PlayerRegistry
end

function PlayerRegistry:Init()
	self.Players = { }
end

function PlayerRegistry:PrimeName( playerID, name )
	if not self.Names then self.Names = { } end
	self.Names[ playerID ] = name
end

function PlayerRegistry:RegisterPlayer( player )
	if player.ID then return end

	if ( not player.Name or string.len( player.Name ) == 0 ) and
	   ( self.Names and self.Names[ player.UserID ] ) then
		player.Name = self.Names[ player.UserID ]
	end
	player.ID = #self.Players + 1

	table.insert( self.Players, player )

	return player
end

function PlayerRegistry:GetAlivePlayers( filter )
	if type( filter ) == "function" then
		return self:_ApplyFilter( {
			Alive = true,
			Function = filter
		} )
	elseif type( filter ) == "table" then
		filter.Alive = true
		return self:_ApplyFilter( filter )
	else
		return self:GetAllPlayers( { Alive = true } )
	end
end

function PlayerRegistry:GetDeadPlayers( filter )
	if type( filter ) == "function" then
		return self:GetAllPlayers( {
			Alive = false,
			Function = filter
		} )
	elseif type( filter ) == "table" then
		filter.Alive = false
		return self:GetAllPlayers( filter )
	else
		return self:GetAllPlayers( { Alive = false } )
	end
end

function PlayerRegistry:GetAllPlayers( filter )
	if not filter then return self.Players end

	local ret = { }

	for _, v in pairs( self.Players ) do
		if self:_ApplyFilter( v, filter ) then
			table.insert( ret, v )
		end
	end

	return ret
end

function PlayerRegistry:GetPlayer( filter )
	for _, v in pairs( self.Players ) do
		if self:_ApplyFilter( v, filter ) then
			return v
		end
	end
end

function PlayerRegistry:_ApplyFilter( player, filter )
	if not filter then return true end

	if type( filter ) == "function" then
		return filter( player )
	elseif type( filter ) == "table" then
		if filter.Alive ~= nil     and player:IsAlive()  ~= filter.Alive     then return false end
		if filter.Connected ~= nil and player.Connected  ~= filter.Connected then return false end
		if filter.Entity ~= nil    and player.PlayerEntity ~= filter.Entity  then return false end
		if filter.Hero ~= nil      and player.HeroEntity ~= filter.Hero      then return false end
		if filter.Name ~= nil      and player.Name       ~= filter.Name      then return false end
		if filter.PlayerID ~= nil  and player.UserID     ~= filter.PlayerID  then return false end
		if filter.UserID ~= nil    and player.UserID     ~= filter.UserID    then return false end
		if filter.Team ~= nil      and player.Team       ~= filter.Team      then return false end

		-- The function might be heavy, let's leave it for last
		if filter.Function ~= nil  and not filter.Function( player )         then return false end
	end

	return true
end