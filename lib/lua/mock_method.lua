
module( "lmock" , package.seeall )

CMockMethod = {}

function CMockMethod:Ctor( methodName )
	self.m_invoker = {}
	self.m_deactiveInvoker = {}

	assert( type( methodName ) == "string" )
	self.m_name = methodName
end

function CMockMethod.new( methodName )
	local obj = {}
	setmetatable( obj , { __index = CMockMethod } )
	obj:Ctor( methodName )
	return obj
end

function CMockMethod:expects( restrict )
	local invoker = CMockInvoker.new( restrict )
	table.insert( self.m_invoker , invoker )
	return invoker
end

local function default()
	local t = {}
	
	function t:update()
		return true
	end

	function t:validate()
	end

	function t:toString()
		return "  :default()\n"
	end

	return t
end

function CMockMethod:default()
	self.m_defaultInvoker = CMockInvoker.new( default() )
	return self.m_defaultInvoker
end

function CMockMethod:call( ... )
	for idx , invoker in ipairs( self.m_invoker ) do
		if invoker:matchParameter( ... ) then
			self:updateInvoker( idx , invoker , ... )
			return unpack( invoker:excute() )
		end
	end

	if self.m_defaultInvoker and self.m_defaultInvoker:matchParameter( ... ) then
		return unpack( self.m_defaultInvoker:excute() )
	end

	self:printParameterError( ... )
end

function CMockMethod:updateInvoker( idx , invoker , ... )
	local executeRst , active = pcall( invoker.updateRestrict , invoker )
	if executeRst and not active then
		table.insert( self.m_deactiveInvoker , invoker )
		table.remove( self.m_invoker , idx )
	end

	if not executeRst then
		local str = active..self:printCurrentInvoke( ... )..self:printMethodName()..invoker:toString()
		error( str , 4 )
	end
end

function CMockMethod:printParameterError( ... )
	local currentInvoke = self:printCurrentInvoke( ... )
	local allInvokeDefine = self:printAllAllowedInvoke()
	error( "Parameter exception\n"..currentInvoke..allInvokeDefine , 4 )
end

function CMockMethod:printCurrentInvoke( ... )
	local str = "Invoked: "..self.m_name.."("

	for idx , param in ipairs( arg ) do
		str = str..tostring( arg[ idx ] )
		if idx ~= #arg then str = str.."," end
	end

	str = str..")\n"
	
	return str
end

function CMockMethod:printAllAllowedInvoke()
	local str = "Allowed:\n"
	
	local methodName = self:printMethodName()

	for _ , invoker in ipairs( self.m_invoker ) do
		str = str..methodName..invoker:toString()
	end
	
	for _ , invoker in ipairs( self.m_deactiveInvoker ) do
		str = str..methodName..invoker:toString()
	end

	if self.m_defaultInvoker then
		str = str..methodName..self.m_defaultInvoker:toString()
	end

	return str
end

function CMockMethod:printMethodName()
	return string.format( "METHOD(%s)\n" , self.m_name )
end

function CMockMethod:verify()
	local str = ""
	
	local methodName = self:printMethodName()

	for i , invoker in ipairs( self.m_invoker ) do
		if invoker:checkRestrict() then
			str = str..invoker:checkRestrict()..methodName..invoker:toString()
		end
	end

	return string.len( str ) > 0 and str
end

local function stubs()
	local t = {}

	function t:update()
		return true
	end

	function t:validate()
	end

	function t:toString()
		return "  :stubs()\n"
	end

	return t
end

function CMockMethod:stubs()
	return self:expects( stubs() )
end
