Bomb = class({
	constructor = function(self)
		self:Init()
	end
})


function Bomb:Init()
	self:_Reset()
end

function Bomb:Drop()
	self:_Reset()
	CreateItemOnPositionSync( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), self.Item )
end

function Bomb:GetCarrier()
	if IsValidEntity( self.Carrier ) then
		return self.Carrier
	else
		return self.Item:GetContainer()
	end
end

function Bomb:_Reset()
	self.Carrier = nil
	self.Item = CreateItem( "item_bomb", nil, nil )
	self.Item.Bomb = self
	self.LastCarrier = nil
end

function Bomb:StartCountdown()
	if PTB.State ~= PTB.STATE_ROUND then return end

	self.ExplodePoint = GameRules:GetGameTime() + PTB.RoundTime
	self.Countdown = true

	Timers:CreateTimer( function() return self:OnTick() end )
end

function Bomb:Explode()
	if self.Countdown then self.Countdown = nil end

	local reason = self.LastCarrier and self.LastCarrier or self.Carrier
	PTB:ExplodePlayer( self.Carrier, reason  )

	self:Take()
	PTB:EndRound()
end

function Bomb:OnTick()
	local timeLeft = self.ExplodePoint - GameRules:GetGameTime()

	if timeLeft <= 0 then
		self:Explode()

		return
	else
		Say(nil, "Time left: " .. math.ceil( timeLeft ), false)

		return 1
	end
end

function Bomb:Take( skip )
	if self.Carrier then
		self.Carrier:RemoveItem( self.Item )
		self.Carrier = nil
	end

	if IsValidEntity( self.Item ) then
		if IsValidEntity( self.Item:GetContainer() ) then
			print( "Killing container" )
			self.Item:GetContainer():Kill()
		end

		if IsValidEntity( self.Item:GetOwner() ) then
			local owner = self.Item:GetOwner()

			print( "Taking from owner" )
			owner.Player:RemoveItem( self.Item )
		end
	end

	self:_Reset()
end

function Bomb:Pass( player, from )
	if IsValidEntity( player ) then
		player = player.Player
	end

	if (not from or from == self.Carrier) and player ~= self.Carrier then
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
			old_carrier = self.LastCarrier,
			new_carrier = self.Carrier,
			bomb = self
		} )

		print( self.Carrier.Name .. " got a bomb." )
	end
end
