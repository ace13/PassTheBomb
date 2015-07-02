if not Bomb then
	Bomb = class( {
		constructor = function( self )
			self:Init()
		end
	})
	Bombs = {
		Bomb = {}
	}
end


--[[
--   Bomb registry, for multi-bomb modes
--]]

function Bombs.Register( bomb )
	Bombs[ #Bombs + 1 ] = bomb
	bomb.ID = #Bombs
end

function Bombs.Find( id )
	return Bombs[ id ]
end

function Bombs:Remove( bomb )
	if not bomb.ID or not Bombs[ bomb.ID ] then return end
	Bombs[ bomb.ID ] = nil
end


--[[
--   Initializer functions
--]]

function Bomb:Init()
	self:_Reset()
	Bombs:Register( self )
end

function Bomb:_Reset()
	self.Carrier = nil
	self.Item = CreateItem( "item_bomb", nil, nil )
	self.Item.Bomb = self
	self.LastCarrier = nil
end


--[[
--   Accessor functions
--]]

function Bomb:TimeLeft()
	if not self.Countdown then return nil end

	return self.ExplodePoint - GameRules:GetGameTime()
end


--[[
--   Handling functions
--]]

function Bomb:Drop()
	self:_Reset()
	CreateItemOnPositionSync( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), self.Item )
end

function Bomb:Take( skip )
	if self.Carrier then
		self.Carrier:RemoveItem( self.Item )
		self.Carrier = nil
	end

	if IsValidEntity( self.Item ) then
		if IsValidEntity( self.Item:GetContainer() ) then
			self.Item:GetContainer():Kill() -- Remove dropped bomb
		end

		-- Someone other than the carrier holds the bomb, shouldn't be possible.
		-- But hey, better safe than sorry.
		if IsValidEntity( self.Item:GetOwner() ) then
			local owner = self.Item:GetOwner()
			owner.Player:RemoveItem( self.Item ) -- Take bomb item
		end
	end

	self:_Reset()
end

function Bomb:Pass( player, from )
	if player.Player then
		-- Function was given a hero or player entity
		-- So grab the player entry instead
		player = player.Player
	end

	if ( not from or from == self.Carrier ) -- Only allow passing if you actually own the bomb
	     and player ~= self.Carrier then -- Don't care about passing to yourself for now
		if self.Carrier then
			local old = self.Carrier
			old:RemoveItem( self.Item )

			self:_Reset()

			self.LastCarrier = old
		end

		player:AddItem( self.Item )
		self.Carrier = player

		if not self.Countdown then
			self:StartCountdown()
		end

		FireGameEvent( "ptb_bomb_passed", {
			old_carrier = self.LastCarrier and self.LastCarrier.UserID or -1,
			new_carrier = self.Carrier.UserID,
			bomb = self.ID
		} )

		print( self.Carrier.Name .. " got a bomb." )
	end
end

function Bomb:Explode()
	if self.Countdown then self.Countdown = nil end

	local reason = self.LastCarrier and self.LastCarrier or self.Carrier
	PTB:ExplodePlayer( self.Carrier, reason  )

	FireGameEvent( "ptb_bomb_exploded", {
		carrier = self.Carrier.UserID,
		bomb    = self.ID
	} )

	self:Take()
	PTB:EndRound()
end


--[[
--   Timing functions
--]]

function Bomb:StartCountdown()
	if PTB.State ~= STATE_ROUND then return end

	self.ExplodePoint = GameRules:GetGameTime() + PTB.RoundTime
	self.Countdown = true

	Timers:CreateTimer( function() return self:OnTick() end )
end

function Bomb:OnTick()
	local timeLeft = self.ExplodePoint - GameRules:GetGameTime()

	if timeLeft <= 0 then
		self:Explode()

		return
	else
		local nicetime = math.ceil( timeLeft )

		Messages:Number( {
			Target = self.Carrier.HeroEntity,
			Number = nicetime,
			Color = Vector( 255, 0, 0 )
		} )

		return 1
	end
end


