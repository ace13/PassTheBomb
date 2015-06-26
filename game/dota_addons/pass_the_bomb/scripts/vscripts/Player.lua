Player = class({
		Points = 0,
		State = 1
	})

Player.STATE_CONNECTED = 1
Player.STATE_ALIVE = 2

function Player:OnConnect( event )
	self.Entity = EntIndexToHScript( event.index + 1 )

	if not IsValidEntity( self.Entity ) then
		error( "Invalid player entity!" )
		return
	end

	self:Validate( event )

	if self.Reconnecting then
		self.Reconnecting = nil

		print( "Player " .. self.Name .. " returns to the fray." )

		PTB:ReturningPlayer( self )
	end
end

function Player:OnDisconnect( event )
	self:Validate( event )

	print( "Player " .. self.Name .. " left the game." )

	if IsValidEntity( self.Entity ) and IsValidEntity( self.Entity:GetAssignedHero() ) then
		PTB:ExplodePlayer( self, self.Hero:FindAbilityByName( "techies_pass_the_bomb" ), self )
	end

	PTB:PlayerDisconnected( self )
end

function Player:OnReconnect( event )
	self.Reconnecting = true
end

function Player:OnSpawn( event )
	if IsValidEntity( self.Hero ) then
		print( "Player " .. self.Name .. " is respawning." )

		self.Hero:SetAngles( 0, math.random(360), 0 )

		return
	end

	print( "Player " .. self.Name .. " is spawning." )

	self.Hero = EntIndexToHScript( event.entindex )
	self:Validate( event )

	self.Hero:SetAngles( 0, math.random(360), 0 )
	self:InitTeam()

	self.Hero:SetAbilityPoints( 0 )

	local ability = self.Hero:FindAbilityByName( "techies_blink" )
	ability:SetLevel( 1 )

	-- local ability = self.Hero:FindAbilityByName( "techies_pass_the_bomb" )
end

function Player:OnJoinTeam( event )
	self:Validate( event )

	print( "Player " .. self.Name .. " joins team " .. event.team .. "." )
end

function Player:InitTeam()
	local id = PlayerResource:GetCustomTeamAssignment( self.ID )
	self:SetTeam( id )
end

function Player:SetTeam( teamid )
	if not teamid then return end

	local id = PlayerResource:GetCustomTeamAssignment( self.ID )
	if id ~= teamid then
		print( "Setting player " .. self.ID .. " from team " .. id .. " to " .. teamid )
		PlayerResource:SetCustomTeamAssignment( self.ID, teamid )
	end

	self.Team = PlayerResource:GetCustomTeamAssignment( self.ID )

	if IsValidEntity( self.Hero ) then
		self.Hero:SetTeam( self.Team )
	end

	if Teams.Colors[ teamid ] then
		local col = Teams.Colors[ teamid ]
		PlayerResource:SetCustomPlayerColor( self.ID, col[ 1 ], col[ 2 ], col[ 3 ] )
	end
end

function Player:Validate( event )
	local oldid = self.ID or nil

	if event then
		if not self.UserID and event.userid then self.UserID = event.userid end
		if not self.Name and event.name then self.Name = event.name end
	end

	if self.Entity then
		if not self.ID then 
			local id = self.Entity:GetPlayerID()
			if id >= 0 then self.ID = id end
		end
	end
	if self.Hero then
		if not self.Entity then self.Entity = self.Hero:GetPlayerOwner() end
		if not self.Hero.Player then self.Hero.Player = self end
	end
	if not self.ID and self.UserID then self.ID = self.UserID - 1 end

	if oldid ~= self.ID then PTB:RegisterPlayer( self ) end
end