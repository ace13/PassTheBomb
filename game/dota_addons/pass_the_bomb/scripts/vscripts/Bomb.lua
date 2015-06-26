Bomb = class({
	OnPasses = { },
	constructor = function(self)
		self.Item = CreateItem( "item_bomb", nil, nil )

		CreateItemOnPositionSync( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), self.Item )
	end
})

function Bomb:GetCarrier()
	if IsValidEntity( self.Carrier ) then
		return self.Carrier
	else
		return self.Item:GetContainer()
	end
end

function Bomb:AddOnPass( id, func )
	self.OnPasses[ id ] = func
end

function Bomb:RemoveOnPass( id )
	self.OnPasses[ id ] = nil
end

function Bomb:Reset()
	--self.Carrier = nil
	--self.LastCarrier = nil

	self.Item = CreateItem( "item_bomb", nil, nil )
end

function Bomb:StartCountdown()
	if PTB.State ~= PTB.STATE_ROUND then return end

	self.ExplodePoint = GameRules:GetGameTime() + 30
	self.Countdown = true
end

function Bomb:Explode()
	-- TODO: All of this
	print( "TODO: Your head asplode!" )

	--[[
	CreateEffect( {
		entity = self:Carrier(),
		effect = ""
	} )
	]]

	PTB:End()
end

function Bomb:OnTick()
	--[[
	-- FIXME: Allow picking up.
	if self:Carrier() ~= self.LastCarrier and IsValidEntity( self.Item:GetOwner() ) then
		print( self:Carrier().Player.Name .. " picked up the bomb" )
		self:Give( self:Carrier() )
	end
	]]

	-- TODO: Countdown
	if self.Countdown then
		local timeLeft = self.ExplodePoint - GameRules:GetGameTime()

		Say(nil, "Time left: " .. timeLeft, false)
		if timeLeft <= 0 then
			self:Explode()
			self.Countdown = nil
		end
	end
end

function Bomb:Take()
	if IsValidEntity( self.Carrier ) then
		self.Carrier:FindAbilityByName( "techies_pass_the_bomb" ):SetLevel(0)
		self.Carrier:RemoveItem( self.Item )
	end

	self:Reset()
end

local function hasItem( hero, item )

end

function Bomb:Pass( hero, from )
	if (not from or from == self.Carrier) and hero ~= self.Carrier then
		if IsValidEntity( self.Carrier ) then
			self.Carrier:FindAbilityByName( "techies_pass_the_bomb" ):SetLevel(0)
			self.Carrier:RemoveItem( self.Item )
			self:Reset()

			self.LastCarrier = self.Carrier
		end

		hero:AddItem( self.Item )

		if not IsValidEntity( self.Carrier ) then
			self:StartCountdown()
		end
		self.Carrier = hero
		self.Carrier:FindAbilityByName( "techies_pass_the_bomb" ):SetLevel(1)

		for _,v in pairs( self.OnPasses ) do
			v( self.LastCarrier, self.Carrier, bomb )
		end

		print( self.Carrier.Player.Name .. " got the bomb." )
	end
end
