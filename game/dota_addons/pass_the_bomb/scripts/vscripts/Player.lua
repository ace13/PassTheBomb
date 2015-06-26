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

	if self.Reconnecting then
		self.Reconnecting = nil

		print( "Player " .. self.Name .. " returns to the fray." )

		PTB:ReturningPlayer( self )
	else
		self.Index = event.index
		self.UserID = event.userid

		local id = self.Entity:GetPlayerID()
		print( "PlayerID: " .. id )
		if id > -1 then
			self.ID = id
		end

		PTB:RegisterPlayer( self )
	end
end

function Player:OnDisconnect( event )
	print( "Player " .. self.Name .. " left the game." )

	if IsValidEntity( self.Entity:GetAssignedHero() ) then
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

	self.Hero:SetAngles( 0, math.random(360), 0 )

	if not IsValidEntity( self.Entity ) then
		self.Entity = self.Hero:GetPlayerOwner()
		if not IsValidEntity( self.Entity ) then
			error( "Player has spawned without a proper entity, this is a bad thing(tm)" )
		else
			local id = self.Entity:GetPlayerID()
			print( "PlayerID:", id )
			if id > -1 then
				self.ID = id
			end
		end
	end

	self.Hero.Player = self
	self.Hero:SetAbilityPoints( 0 )

	local ability = self.Hero:FindAbilityByName( "techies_blink" )
	ability:SetLevel( 1 )

	-- local ability = self.Hero:FindAbilityByName( "techies_pass_the_bomb" )
end

function Player:OnJoinTeam( event )
	if not self.UserID and event.userid then
		self.UserID = event.userid

		PTB:RegisterPlayer( self )
	end

	if self.Entity then
		local id = self.Entity:GetPlayerID()
		if id > -1 then
			self.ID = id
		end
		print( "PlayerID:", id )
	end

	if event.name and not self.Name then
		self.Name = event.name
	end

	print( "Player " .. self.Name .. " joins team " .. event.team .. "." )
end

function Player:SetTeam( teamid )
	if self.ID then
		local curteam = PlayerResource:GetCustomTeamAssignment( self.ID )
		if curteam ~= teamid then
			PlayerResource:SetCustomTeamAssignment( self.ID, teamid )
			local col = Teams.Colors[ teamid + 1 ]
			PlayerResource:SetCustomPlayerColor( self.ID, col[ 1 ], col[ 2 ], col[ 3 ] )
		end
	end

	if IsValidEntity( self.Hero ) then
		self.Hero:SetTeam( teamid )
	end
end
