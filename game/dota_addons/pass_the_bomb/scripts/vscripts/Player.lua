Player = class({
		Deaths = 0,
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
		if id ~= 1 then
			self.ID = id
			self.SteamID = PlayerResource:GetSteamAccountID( self.ID )
		end

		PTB:RegisterPlayer( self )
	end
end

function Player:OnDisconnect( event )
	print( "Player " .. self.Name .. " left the game." )

	if IsValidEntity( self.Entity:GetAssignedHero() ) then
		print( "TODO: Kill the leaver!" )
		-- PTB:ExplodePlayer( self )
	end

	PTB:PlayerDisconnected( self )
end

function Player:OnReconnect( event )
	self.Reconnecting = true
end

function Player:OnSpawn( event )
	print( "Player " .. self.Name .. " is spawning." )

	self.Hero = EntIndexToHScript( event.entindex )
	self.Hero.Player = self

	-- FIXME: Be data driven instead
	fixme( "Create data-driven abilities" )

	self.Hero:AddAbility( "antimage_blink" )
	local ability = self.Hero:FindAbilityByName( "antimage_blink" )
	ability:SetLevel( 4 )

	self.Hero:SwapAbilities( "techies_land_mines", "antimage_blink", false, true )


	

	--[[
	for i = 0, 15 do
		local ability = self.Hero:GetAbilityByIndex( i )

		if ability then 
			self.Hero:RemoveAbility( ability:GetName() )
		end
	end
	]]
end

function Player:OnJoinTeam( event )
	if event.name and not self.Name then
		self.Name = event.name
		self.IsBot = event.isbot
	end

	print( "Player " .. self.Name .. " joins team " .. event.team .. "." )
end
