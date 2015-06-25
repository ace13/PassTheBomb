function LoadModule( name )
	local mod = nil
	local st, err = pcall( function()
			mod = require( name )
		end )

	if st then
		print( "- " .. name .. "." )
	else
		print( "- " .. name .. " Failed!\n    " .. err )

		mod = nil
	end

	return mod
end

function fixme( ... )
	print( "FIXME: ", ... )
end
