Messages = Messages or {}

MESSAGE_TOP = 0
MESSAGE_CENTER = 1
MESSAGE_BOTTOM = 2
MESSAGE_TICKER = 3

SYMBOL_PRE_PLUS = 0
SYMBOL_PRE_MINUS = 1
SYMBOL_PRE_SADFACE = 2
SYMBOL_PRE_BROKENARROW = 3
SYMBOL_PRE_SHADES = 4
SYMBOL_PRE_MISS = 5
SYMBOL_PRE_EVADE = 6
SYMBOL_PRE_DENY = 7
SYMBOL_PRE_ARROW = 8

SYMBOL_POST_EXCLAMATION = 0
SYMBOL_POST_POINTZERO = 1
SYMBOL_POST_MEDAL = 2
SYMBOL_POST_DROP = 3
SYMBOL_POST_LIGHTNING = 4
SYMBOL_POST_SKULL = 5
SYMBOL_POST_EYE = 6
SYMBOL_POST_SHIELD = 7
SYMBOL_POST_POINTFIVE = 8

--[[
--   Helper functions
--]]

local function ColToHex( color )
	return string.format( "%x%x%x", color[ 1 ], color[ 2 ], color[ 3 ] )
end


--[[
--   Initializer functions
--]]

function Messages:Init()

end


--[[
--   Message functions
--]]

function Messages:Display( message, data )
	data = data or {}

	local time = data.Duration and tonumber( data.Duration ) or 1
	local where = data.Type and tonumber( data.Type ) or MESSAGE_BOTTOM
	local color = data.Color or Vector( 255, 255, 255 )

	print( "TODO: Messages:Display" )
	if where == MESSAGE_TICKER then
		if color then
			message = "<font color=\"#" .. ColToHex( color )  .. "\">" .. message .. "</font>"
		end
		SendCustomMessage( message, -1, 1 )
	else
		Say( nil, message, false )
	end
end

function Messages:Number( data )
	if not data then error( "Missing parameter" ) end
	local target = data.Target
	if not IsValidEntity( target ) then error( "Needs valid target" ) end

	local number     = data.Number and tonumber( data.Number ) or nil
	local fx_file    = data.Type and tostring( data.Type ) or "miss"
	local color      = data.Color or Vector( 255, 255, 255 )
	local duration   = data.Duration and tonumber( data.Duration ) or 1
	local presymbol  = data.PreSymbol and tonumber( data.PreSymbol ) or nil
	local postsymbol = data.PostSymbol and tonumber( data.PostSymbol ) or nil
	local path       = "particles/msg_fx/msg_" .. fx_file .. ".vpcf"
        local particle   = ParticleManager:CreateParticle( path, PATTACH_ABSORIGIN_FOLLOW, target )

	local digits = 0
	if number ~= nil then digits = #tostring( number ) end
	if presymbol ~= nil then digits = digits + 1 end
	if postsymbol ~= nil then digits = digits + 1 end

        ParticleManager:SetParticleControl( particle, 1, Vector( presymbol, number, postsymbol ) )
	ParticleManager:SetParticleControl( particle, 2, Vector( duration, digits, 0 ) )
	ParticleManager:SetParticleControl( particle, 3, color )
end
Messages.Popup = Messages.Number


--[[
--   Announcer functions
--]]

function Messages:Announce( announcement, data )
	print( "TODO: Announcer '" .. announcement "'" )
end

return Messages
