
module( "lmock" , package.seeall )

CMockEnv = {}

function CMockEnv:Ctor( env )
	assert( type(env) == "table" )
	self.m_env = env
	self.m_methods = {}
end

function CMockEnv.new( env )
	local obj = {}
	setmetatable( obj , { __index = CMockEnv } )
	obj:Ctor( env )
	return obj
end

local fmtModule = "^[_a-zA-Z]+[_a-zA-Z0-9]*%."
local fmtObject = "^[_a-zA-Z]+[_a-zA-Z0-9]*:"

local function checkMethodExist( methodName )
	local str = methodName
	local first , last = string.find( str , fmtModule )
	local checkEnv = _G
	while first do
		local moduleName = string.sub( str , first , last-1 )
		checkEnv[ moduleName ] = checkEnv[ moduleName ] or {}
		checkEnv = checkEnv[ moduleName ]
		
		str = string.sub( str , last+1 )
		first , last = string.find( str , fmtModule )
	end

	first , last = string.find( str , fmtObject )
	if first then
		local objName = string.sub( str , first , last-1 )
		checkEnv[ objName ] = checkEnv[ objName ] or {}
		checkEnv = checkEnv[ objName ]
		
		str = string.sub( str , last+1)
		func = memberFunc
	end

	if type( checkEnv[str] ) ~= "function" then
		error( methodName.."@METHOD is not exist , please check" , 2 )
	end
end

local function createUnpolluteGEnv( env , moduleName )
	return ( _G == env._G and ( _G[ moduleName ] ~= env[ moduleName ] and env[ moduleName ] or {} ) ) 
			or env[ moduleName ] or {}
end

local function buildMethodEnv( env , methodName , func , memberFunc )
	local str = methodName
		
	local first , last = string.find( str , fmtModule )	
	while first do
		local moduleName = string.sub( str , first , last-1 )
		env[ moduleName ] = createUnpolluteGEnv( env , moduleName )
		env = env[ moduleName ]
		
		str = string.sub( str , last+1 )
		first , last = string.find( str , fmtModule )
	end

	first , last = string.find( str , fmtObject )
	if first then
		local objName = string.sub( str , first , last-1 )
		env[ objName ] = createUnpolluteGEnv( env , objName )
		env = env[ objName ]
		str = string.sub( str , last+1)

		func = memberFunc
	end

	env[str] = func
end

function CMockEnv:method( methodName , check )
	if not self.m_methods[ methodName ] then
		self.m_methods[ methodName ] = CMockMethod.new( methodName )
		local method = self.m_methods[ methodName ]

		local function func( ... )
			return method:call( ... )
		end

		local function memberFunc( obj , ... )
			return method:call( ... )
		end
		
		if check then
			checkMethodExist( methodName )
		end
		buildMethodEnv( self.m_env , methodName , func , memberFunc )
	end

	return self.m_methods[ methodName ]
end

function CMockEnv:verify()
	local allRet = ""
	for name , method in pairs( self.m_methods ) do
		local ret = method:verify()
		if ret then
			allRet = allRet..ret.."\n"
		end
	end
	if string.len( allRet ) > 0 then
		error( allRet , 2 )
	end
end

function CMockEnv:run( testee , ... )
	local oldEnv = getfenv( testee )
	setfenv( testee , self.m_env )
	local ret = { testee( ... ) }
	setfenv( testee , oldEnv )
	return unpack( ret )
end
