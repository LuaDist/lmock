require"luaunit"
require"mock_env"
require"mock_method"
require"mock_invoker"

module( "lmock" , package.seeall )

function create()
	local tmpEnv = {}
	setmetatable( tmpEnv , { __index = _G } )
	setfenv( 2 , tmpEnv )

	mock = CMockEnv.new( tmpEnv )
	return mock
end

function once()
	local t = {}
	local active = true

	function t:update()
		active = false
		return active
	end

	function t:validate()
		if active then
			return "Invocation was never invoked\n"
		end
	end

	function t:toString()
		if active then
			return 
[[  :expects(lmock.once())
  :invoke(0)
]]
		else
			return 
[[  :expects(lmock.once())
  :invoke(1)
]]
		end
	end

	return t
end

function eq( expectValue )
	local t = {}

	function t:test( actureValue )
		return expectValue == actureValue
	end

	function t:toString()
		if type( expectValue ) == "string" then
			return string.format( "lmock.eq(\"%s\")" , expectValue )
		end

		return string.format( "lmock.eq(%s)" , tostring( expectValue ) )
	end

	return t
end

function eqx( expectValue )
	return eq( expectValue )
end

function any()
	local t = {}

	function t:test()
		return true
	end

	function t:toString()
		return "lmock.any()"
	end

	return t
end

function exactly( value )
	local t = {}
	local cnt = 0
	
	function t:update()
		cnt = cnt + 1
		return cnt < value
	end

	function t:validate()
		return cnt < value and "Invocation times and acture invoked time mismatch\n"
	end

	function t:toString()
		return string.format( 
[[  :expects(lmock.exactly(%d))
  :invoke(%d)
]] , 
		value , cnt )
	end

	return t
end

function range( low , up )
	local t = {}
	local cnt = 0
	
	function t:update()
		cnt = cnt + 1
		return cnt < up
	end

	function t:validate()
		return cnt < low and "Invoked too few times\n"
	end

	function t:toString()
		return string.format( 
[[  :expects(lmock.range(%d,%d))
  :invoke(%d)
]] , 
		low , up , cnt )
	end

	return t
end

function never()
	local t = {}

	function t:update()
		error( "Invocation should never invoked\n" , 2 )
	end

	function t:validate()
	end

	function t:toString()
		return "  :expects(lmock.never())\n"
	end

	return t
end
