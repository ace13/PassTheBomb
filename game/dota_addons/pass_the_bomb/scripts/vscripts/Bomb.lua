Bomb = class({
	constructor = function(self, owner, position)
		self.Item = CreateItem( "item_blink", nil, nil )

		if IsValidEntity(owner) then
			owner:AddItem( self.Item )
		elseif position then
			CreateItemOnPositionSync( position, self.Item )
		else
			CreateItemOnPositionSync( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), self.Item )
		end

		self.Item:AddSpeechBubble( 0, "Hello, I am your friendly neigborhood IED", 5, 0, 0 )
	end
})


function Bomb:Carrier()
	if IsValidEntity( self.Item:GetOwner() ) then
		return self.Item:GetOwner()
	else
		return self.Item:GetContainer()
	end
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
end

function Bomb:Tick()
	-- TODO: Countdown
end
