local Mode = {}
Mode.Name = "Super Toss"

function Mode:Init()
	print( "Toss:Init" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			hero:GetAbilityByName( "techies_pass_the_bomb" ):SetLevel( 2 )
		end
	end
end

function Mode:Cleanup()
	print( "Toss:Cleanup" )

	for _, p in pairs( PTB.Players ) do
		local hero = p.Entity:GetAssignedHero()

		if IsValidEntity( hero ) then
			hero:GetAbilityByName( "techies_pass_the_bomb" ):SetLevel( 1 )
		end
	end
end

return Mode