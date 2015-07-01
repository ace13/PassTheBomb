if not oldPrint then
	oldPrint = print
end

function LoadModule( name )
	local mod = nil
	local st, err = pcall( function()
			mod = require( name )
		end )

	if st then
		oldPrint( "- " .. name .. " Loaded." )
	else
		oldPrint( "- " .. name .. " Failed!\n    " .. err )

		mod = nil
	end

	return mod
end

function PrintTable( t, level, seen )
	if type(t) ~= "table" then return end

	seen = seen or { }
	seen[ t ] = true

	level = level or 0
	local indent = string.rep( "\t", level + 1 )
	local braceIndent = string.rep( "\t", level )

	local longest_key = 8
	local keys = { }
	for k, _ in pairs( t ) do
		table.insert( keys, k )

		local len = string.len( tostring( k ) )
		if len > longest_key then longest_key = len end
	end
	longest_key = longest_key + 1

	oldPrint( braceIndent .. "{" )

	table.sort( keys )
	for _, k in ipairs( keys ) do
		if k ~= 'FDesc' then -- Ignore FDesc
			local value = t[ k ]

			if type( value ) == "table" then
				if not seen[ value ] then
					oldPrint( string.format( "%s( table  ) %s:",
						indent,
						tostring( k )
					) )
					PrintTable( value, level + 1, seen )
				else
					oldPrint( string.format( "%s( table  ) %s: (seen as %s)",
						indent,
						tostring( k ),
						tostring( value )
					) )
				end
			elseif type( value ) == "userdata" then
				if not seen[ value ] then
					oldPrint( string.format( "%s(userdata) %s: %s%q",
						indent,
						tostring( k ),
						string.rep( " ", longest_key - string.len( tostring( k ) ) ),
						tostring( value )
					) )
					local met = getmetatable(value)
					
					PrintTable( met and met._index or met, level + 1, seen )
				else
					oldPrint( string.format( "%s(userdata) %s: %s%q (already seen)",
						indent,
						tostring( k ),
						string.rep( " ", longest_key - string.len( tostring( k ) ) ),
						tostring( value )
					) )
				end

				seen[ value ] = true
			elseif t.FDesc and t.FDesc[ k ] then
				oldPrint( string.format( "%s(%s) %s: %s%q (%s)",
					indent,
					string.sub( type( value ), 1, 8 ),
					tostring( k ),
					string.rep( " ", longest_key - string.len( tostring( k ) ) ),
					tostring( value ),
					tostring( t.FDesc[ k ] ) )
				)
			else
				oldPrint( string.format( "%s(%s) %s: %s%q",
					indent,
					string.sub( type( value ), 1, 8 ),
					tostring( k ),
					string.rep( " ", longest_key -string.len( tostring( k ) ) ),
					tostring( value )
				) )
			end
		end
	end

	oldPrint( braceIndent .. "}" )
end

function print( ... )
	local toPrint = ""
	for _, v in pairs( { ... } ) do
		toPrint = toPrint .. "\t" .. tostring( v )
	end

	oldPrint( "[" .. GetSystemTime() .. "] PTB =>" .. toPrint )
end

function SeedRandom( seed )
	if not seed then
		seed = 0

		local time = GetSystemTime()
		local size = 60 * 60

		-- Add together the time data into a seconds count
		for val in string.gmatch( time, "%d+" ) do
			seed = seed + tonumber( val ) * size
			size = size / 60
		end
	end

	math.randomseed( tonumber( seed ) )
end

-- FIXME: Add UI pieces for this
function ShowMessage( message )
	print( "ShowMessage: " .. tostring( message ) )
	Say( nil, tostring( message ), false )
end
