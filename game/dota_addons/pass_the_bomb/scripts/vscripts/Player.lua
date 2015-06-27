if not Player then
	Player = class({ })
	getmetatable( Player ).__tostring = Player.ToString
end

VISION_DAY = 0
VISION_NIGHT = 1
VISION_CURRENTLY = 2


function Player.Create( playerID )
	local ply = Player()

	ply.UserID = playerID
	ply:Init()
	ply:_InitPlayer()
	ply:_InitTeam()

	return ply
end


--[[
--   Initializer functions
--]]

function Player:Init()
	self.Alive = false
	self.Connected = true
	self.HeroEntity = nil
	self.Name = nil
	self.PlayerEntity = nil
	self.Score = 0
end

function Player:_InitHero( entity )
	--print( "Player:_InitHero" )

	self.Spawned = true

	self.HeroEntity = entity
	self.HeroEntity.Player = self
	
	self.HeroEntity:SetAngles( 0, math.random(360), 0 )
	self.HeroEntity:SetAbilityPoints( 0 )
	self.HeroEntity:SetGold( 0, false )

	self:SetAbilityLevel( "techies_blink", 1 )
end

function Player:_InitPlayer()
	--print( "Player:_InitPlayer" )

	self.Fake = PlayerResource:IsFakeClient( self.UserID )
	self.Name = PlayerResource:GetPlayerName( self.UserID )
	self.PlayerEntity = PlayerResource:GetPlayer( self.UserID )
	self.PlayerEntity.Player = self
	self.SteamID = PlayerResource:GetSteamAccountID( self.UserID )
end

function Player:_InitTeam()
	--print( "Player:_InitTeam" )

	self:SetTeam( DOTA_TEAM_CUSTOM_MAX )
end


--[[
--   Helper functions
--]]

-- Hero state
function Player:IsAlive()
	return IsValidEntity( self.HeroEntity ) and self.HeroEntity:IsAlive() or false
end

function Player:GetTeam()
	return PlayerResource:GetCustomTeamAssignment( self.UserID )
end

function Player:SetTeam( teamID )
	if not teamID then return end

	PlayerResource:SetCustomTeamAssignment( self.UserID, teamID )
	self.Team = PlayerResource:GetCustomTeamAssignment( self.UserID )

	if self.Team ~= teamID then
		PrintTable( self )
		error( self.Name .. " failed to set team to " .. teamID .. "!" )
	end

	if IsValidEntity( self.HeroEntity ) then
		self.HeroEntity:SetTeam( self.Team )
	end
end

function Player:GetBaseSpeed()
	if not self.BaseMove and IsValidEntity( self.HeroEntity ) then
		self.BaseMove = self.HeroEntity:GetBaseMoveSpeed()
	end
	return self.BaseMove
end

function Player:GetSpeed()
	return IsValidEntity( self.HeroEntity ) and self.HeroEntity:GetBaseMoveSpeed() or nil
end

function Player:SetSpeed( speed )
	if not IsValidEntity( self.HeroEntity ) then return end
	if not self.BaseMove then self.BaseMove = self.HeroEntity:GetBaseMoveSpeed() end

	self.HeroEntity:SetBaseMoveSpeed( speed )
end

local function GetCurrentVision()
	local time = GameRules:GetTimeOfDay( )
	if time > 0.25 and time < 0.75 then
		return VISION_DAY
	else
		return VISION_NIGHT
	end
end

function Player:GetBaseVision( vision )
	if not IsValidEntity( self.HeroEntity ) then return end
	if not vision or vision == VISION_CURRENTLY then vision = GetCurrentVision() end

	if vision == VISION_DAY then
		if not self.BaseDayVision then self.BaseDayVision = self.HeroEntity:GetBaseDayTimeVisionRange() end
		return self.BaseDayVision
	else
		if not self.BaseNightVision then self.BaseNightVision = self.HeroEntity:GetBaseNightTimeVisionRange() end
		return self.BaseNightVision
	end
end

function Player:GetVision( vision )
	if not IsValidEntity( self.HeroEntity ) then return end
	if not vision or vision == VISION_CURRENTLY then vision = GetCurrentVision() end

	return vision == VISION_DAY and
		self.HeroEntity:GetDayTimeVisionRange() or
		self.HeroEntity:GetNightTimeVisionRange()
end

function Player:SetVision( length, vision )
	if not IsValidEntity( self.HeroEntity ) then return end
	if not vision or vision == VISION_CURRENTLY then vision = GetCurrentVision() end

	if vision == VISION_DAY then
		if not self.BaseDayVision then self.BaseDayVision = self.HeroEntity:GetBaseDayTimeVisionRange() end
		self.HeroEntity:SetDayTimeVisionRange( length )
	else
		if not self.BaseNightVision then self.BaseNightVision = self.HeroEntity:GetBaseNightTimeVisionRange() end
		self.HeroEntity:SetNightTimeVisionRange( length )
	end
end

function Player:SetVisionMod( mod, vision )
	if not IsValidEntity( self.HeroEntity ) then return end
	if not vision or vision == VISION_CURRENTLY then vision = GetCurrentVision() end

	local range = self:GetBaseVision( vision )
	self:SetVision( range * mod, vision )
end

-- Inventory handling
function Player:AddItem( item )
	if not IsValidEntity( self.HeroEntity ) then return end

	if type( item ) == "string" then
		if item == "item_bomb" and not self:HasItem( "item_bomb" ) then
			self:SetAbilityLevel( "techies_pass_the_bomb", 1 )
		end
		self.HeroEntity:AddItemByName( "item_bomb" )
		return	
	end

	if not IsValidEntity( item ) then return end

	if item:GetAbilityName() == "item_bomb" and not self:HasItem( "item_bomb" ) then
		self:SetAbilityLevel( "techies_pass_the_bomb", 1 )
	end

	self.HeroEntity:AddItem( item )
end

function Player:GetItem( itemname )
	if not IsValidEntity( self.HeroEntity ) then return end

	for i = 0, 6 do
		local item = self.HeroEntity:GetItemInSlot( i )

		if item:GetAbilityName() == itemname then
			return item
		end
	end
end

function Player:HasItem( item )
	if not IsValidEntity( self.HeroEntity ) then return end

	local itemname = item
	if type( item ) ~= "string" then
		itemname = item:GetAbilityName()
	end

	return self.HeroEntity:HasItemInInventory( item )
end

function Player:RemoveItem( item )
	if not IsValidEntity( self.HeroEntity ) or not IsValidEntity( item ) then return end

	if item:GetAbilityName() == "item_bomb" then
		self:SetAbilityLevel( "techies_pass_the_bomb", 0 )
	end

	self.HeroEntity:RemoveItem( item )
end

-- Ability handling
function Player:HasAbility( ability )
	return IsValidEntity( self.HeroEntity ) and self.HeroEntity:HasAbility( ability ) or false
end

function Player:GetAbility( name )
	return IsValidEntity( self.HeroEntity ) and self.HeroEntity:FindAbilityByName( name ) or nil
end

function Player:RemoveAbility( name )
	if not IsValidEntity( self.HeroEntity ) then return end
	self.HeroEntity:RemoveAbility( name )
end

function Player:SetAbilityLevel( name, level, give )
	if not IsValidEntity( self.HeroEntity ) then return end

	local ability = self:GetAbility( name )
	if not IsValidEntity( ability ) and give then
		self.HeroEntity:AddAbility( name )
		ability = self:GetAbility( name )
	elseif not IsValidEntity( ability ) then
		PrintTable( self )
		error( "Player doesn't have ability " .. name )
	end

	ability:SetLevel( level )
end


--[[
--   Event management
--]]

function Player:OnConnected( event )
	if self.Connected then return end

	self.Connected = true

	print( self.Name .. " reconnected to the game!" )
end

function Player:OnConnectedFull( event )

end

function Player:OnDied( event )
	print( self.Name .. " died!" )

	self.Alive = false
end

function Player:OnDisconnected( event )
	if not self.Connected then return end

	self.Connected = false
	PTB:ExplodePlayer( self, self )

	print( self.Name .. " disconnected from the game!" )
end

function Player:OnGainedLevel( event )
	print( self.Name .. " gains a level!" )

	if IsValidEntity( self.HeroEntity ) then self.HeroEntity:SetAbilityPoints( 0 ) end
end

function Player:OnItemPickedup( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )

	print( self.Name .. " picks up a " .. event.itemname )

	if item.Bomb then
		self:SetAbilityLevel( "techies_pass_the_bomb", 1 )
		item.Bomb.Carrier = self
	end
end

function Player:OnJoinedTeam( event )
	print( self.Name .. " joins team " .. event.team )

	self.Team = event.team

	if Teams.Colors[ self.Team ] then
		local col = Teams.Colors[ self.Team ]
		PlayerResource:SetCustomPlayerColor( self.UserID, col[ 1 ], col[ 2 ], col[ 3 ] )
	end

	if IsValidEntity( self.HeroEntity ) then
		self.HeroEntity:SetTeam( self.Team )
		self.HeroEntity:SetPlayerID( self.UserID )

		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if i ~= self.UserID then
				self.HeroEntity:SetControllableByPlayer( i, false )
			end
		end
	end

	if IsValidEntity( self.PlayerEntity ) then
		local newID = self.PlayerEntity:GetPlayerID()
		if newID ~= self.UserID then
			if newID == -1 then
				PrintTable( self )
				print( self.Name .. " trying to set -1 playerid, why?" )
				return
			end

			print( self.Name .. " is changing ID from " .. self.UserID .. " to " .. newID )

			self.UserID = newID
		end
	end
end

function Player:OnKilled( event )
	print( self.Name .. " got a kill!" )
end

function Player:OnSpawned( event )
	if not self.FirstSpawn then
		self.FirstSpawn = true
		self:_InitHero( EntIndexToHScript( event.entindex ) )

		print( self.Name .. " spawned!" )
	else
		print( self.Name .. " respawned!" )
	end

	self.Alive = true

	PrintTable( self )
end


--[[
--   Utility functions
--]]

function Player:ToString()
	return FormatTable( self )
end

--[[
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
	local id = PlayerResource:GetCustomTeamAssignment( self.UserID )
	self:SetTeam( id )
end

function Player:SetTeam( teamid )
	if not teamid then return end

	self:Validate()

	local id = PlayerResource:GetCustomTeamAssignment( self.UserID )
	if id ~= teamid then
		print( "Setting player " .. self.UserID .. " from team " .. id .. " to " .. teamid )
		PlayerResource:SetCustomTeamAssignment( self.UserID, teamid )
	end

	self.Team = PlayerResource:GetCustomTeamAssignment( self.UserID )

	if IsValidEntity( self.Hero ) then
		self.Hero:SetTeam( self.Team )
	end

	if Teams.Colors[ teamid ] then
		local col = Teams.Colors[ teamid ]
		PlayerResource:SetCustomPlayerColor( self.UserID, col[ 1 ], col[ 2 ], col[ 3 ] )
	end
end

function Player:Validate( event )
	if event then
		if not self.UserID and event.userid then self.UserID = event.userid end
		if not self.Name and event.name then self.Name = event.name end
	end

	if self.Hero then
		if not self.Entity then self.Entity = self.Hero:GetPlayerOwner() end
		if not self.Hero.Player then self.Hero.Player = self end
	end

	if self.Entity then
		if not self.UserID then self.UserID = self.Entity:GetUserID() end
	end

	if not self.ID then PTB:RegisterPlayer( self ) end

	print( "Player:Validate" )
	print( "> " .. self:__tostring() )
end

function Player:__tostring()
	local ret = ""

	if self.ID then ret = "#" .. self.ID .. " " end
	if self.Name then ret = ret .. self.Name .. " " end
	if self.UserID then ret = ret .. "(" .. self.UserID .. ") " end
	ret = ret .. "{\n"
	if self.Entity then ret = ret .. "  UserID: " .. self.Entity:GetUserID() .. "\n" end
	if self.Hero then ret = ret .. "  Hero: " .. tostring( self.Hero ) .. "\n" end
	ret = ret .. "}"

	return ret
end
]]
