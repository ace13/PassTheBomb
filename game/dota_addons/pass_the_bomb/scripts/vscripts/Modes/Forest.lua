local Mode = {}
Mode.Name = "Forest"

function Mode:Init()
	print( "Forest:Init" )

	GameRules:SetTimeOfDay( 0.26 )
	self.Running = false

	self.Listener = ListenToGameEvent( "ptb_bomb_passed", Dynamic_Wrap( self, 'BombPassed' ), self )
	self.Timer = Timers:CreateTimer( function() 
		self:AddTree()

		if not self.Running then
			self:AddTree()
			self:AddTree()
		end

		return 0.5
	end )
end

function Mode:Start()
	print( "Forest:Start" )

	self.Running = true

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetAbilityLevel( "techies_blink", 0 )
	end
end

function Mode:Cleanup()
	print( "Forest:Cleanup" )

	Timers:RemoveTimer( self.Timer )
	StopListeningToGameEvent( self.Listener )

	for _, p in pairs( PlayerRegistry:GetAllPlayers() ) do
		p:SetAbilityLevel( "techies_blink", 1 )
	end

	-- FIXME: Find a proper world origin instead of just bomb_spawn
	GridNav:DestroyTreesAroundPoint( Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin(), 2048, false )
	GridNav:RegrowAllTrees()

	local forests = {
		"Forest of Dean", "Sherwood Forest", "Forestry",
		"Can't see the forest for all the trees", "Timber",
		"Watch out for that tree"
	}

	if RollPercentage( 90 ) then
		self.Name = forests[ math.random( #forests ) ]
	else
		self.Name = "Forest"
	end
end

function Mode:AddTree()
	-- FIXME: Find a proper world origin instead of just bomb_spawn
	local pos = Entities:FindByName( nil, "bomb_spawn" ):GetAbsOrigin() + Vector(
		math.random(-1500, 1500),
		math.random(-1500, 1500),
		0
	)

	-- TODO: Mode heroes off of this position, so they don't get stuck in trees
	CreateTempTree( pos, 30 )
end

function Mode:BombPassed( event )
	local from = PlayerRegistry:GetPlayer( { UserID = event.old_carrier } )
	local to   = PlayerRegistry:GetPlayer( { UserID = event.new_carrier } )

	if from then
		from:SetAbilityLevel( "techies_blink", 0 )
	end

	to:SetAbilityLevel( "techies_blink", 2 )
end

return Mode