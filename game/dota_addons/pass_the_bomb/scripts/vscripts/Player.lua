if not Player then
	Player = class({ })
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
	
	self.HeroEntity:SetAbilityPoints( 0 )
	self.HeroEntity:SetGold( 0, false )

	self:SetAbilityLevel( "techies_blink", 2 )
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

	local teamid = PlayerResource:GetTeam( self.UserID )
	self:SetTeam( teamid )
end

function Player:_ResetHero()
	self.HeroEntity:SetTeam( self.Team )
	self.HeroEntity:SetAbilityPoints( 0 )
	self.HeroEntity:SetAngles( 0, math.random(360), 0 )
	self.HeroEntity:SetDeathXP( 0 )
	self.HeroEntity:SetCustomDeathXP( 0 )
	self.HeroEntity:SetMoveCapability( DOTA_UNIT_CAP_MOVE_GROUND )

	if self.BaseMove then self.HeroEntity:SetBaseMoveSpeed( self.BaseMove ) end
	if self.BaseDayVision then self.HeroEntity:SetDayTimeVisionRange( self.BaseDayVision ) end
	if self.BaseNightVision then self.HeroEntity:SetNightTimeVisionRange( self.BaseNightVision ) end
end


--[[
--   Helper functions
--]]

-- Hero state
function Player:IsAlive()
	return IsValidEntity( self.HeroEntity ) and self.HeroEntity:IsAlive() or false
end

-- Teams
function Player:GetTeam()
	return PlayerResource:GetCustomTeamAssignment( self.UserID )
end

function Player:SetTeam( teamID )
	print( "Player:SetTeam" )
	PrintTable( self )
	print( "Set team to " .. teamID )

	PlayerResource:SetCustomTeamAssignment( self.UserID, teamID )
	self.Team = PlayerResource:GetCustomTeamAssignment( self.UserID )

	if self.Team ~= teamID then
		PrintTable( self )
		error( self.Name .. " failed to set team to " .. teamID .. "!" )
	end

	if Teams.Colors[ self.Team ] then
		local col = Teams.Colors[ self.Team ]
		PlayerResource:SetCustomPlayerColor( self.UserID, col[ 1 ], col[ 2 ], col[ 3 ] )
	end

	if IsValidEntity( self.HeroEntity ) then
		self.HeroEntity:SetTeam( self.Team )
	end
end

-- Speed
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

-- Vision
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

-- Inventory
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
	if not IsValidEntity( self.HeroEntity ) then return end
	if type( item ) == "string" then item = self:GetItem( item ) end

	if not IsValidEntity( item ) then return end
	local name = item:GetAbilityName()

	self.HeroEntity:RemoveItem( item )

	if name == "item_bomb" and not self:HasItem( "item_bomb" ) then
		self:SetAbilityLevel( "techies_pass_the_bomb", 0 )
	end
end

-- Abilities
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
	print( self.Name .. " connected fully!" )
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
	-- print( self.Name .. " gains a level!" )

	if IsValidEntity( self.HeroEntity ) then
		self.HeroEntity:SetAbilityPoints( 0 )
	end
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
	end
end

function Player:OnKilled( event )
	print( self.Name .. " got a kill!" )
end

function Player:OnSpawned( event )
	local hero = EntIndexToHScript( event.entindex )

	if not IsValidEntity( self.HeroEntity ) or hero ~= self.HeroEntity then
		self:_InitHero( hero )

		print( self.Name .. " spawned!" )
	else
		print( self.Name .. " respawned!" )
	end

	self:_ResetHero()
	self.Alive = true

	PrintTable( self )
end
