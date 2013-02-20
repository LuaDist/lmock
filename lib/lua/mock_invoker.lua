module( "lmock" , package.seeall )

CMockInvoker = {}

function CMockInvoker:Ctor( restrict )
	assert( restrict )
	self.m_restrict = restrict
end

function CMockInvoker.new( restrict )
	local obj = {}
	setmetatable( obj , { __index = CMockInvoker } )
	obj:Ctor( restrict )
	return obj
end

function CMockInvoker:excute()
	return self.m_ret or {}
end

function CMockInvoker:matchParameter( ... )
	if not self.m_param then return true end

	local params = { ... }
	for idx , op in ipairs( self.m_param ) do
		local match = op:test( params[ idx ] )
		if not match then return false end
	end

	return true
end

function CMockInvoker:updateRestrict()
	return self.m_restrict:update()
end

function CMockInvoker:with( ... )
	self.m_param = { ... }
	return self
end

function CMockInvoker:will( ... )
	self.m_ret = { ... }
end

function CMockInvoker:checkRestrict()
	return self.m_restrict:validate()
end

function CMockInvoker:toString()
	local str = self.m_restrict:toString()

	if self.m_param then
		str = str..self:printParamString()
	end
	
	if self.m_ret then
		str = str..self:printReturnString()
	end

	return str
end

function CMockInvoker:printParamString()
	local str = "  :with("

	for idx , op in ipairs( self.m_param ) do
		str = str..op:toString()
		if idx ~= #self.m_param then str = str.."," end
	end

	str = str..")\n"

	return str
end

function CMockInvoker:printReturnString()
	local str = "  :will("

	for idx , ret in ipairs( self.m_ret ) do
		if type(ret) == "string" then
			str = str..string.format( "\"%s\"" , ret )
		else
			str = str..tostring( ret )
		end

		if idx ~= #self.m_ret then str = str.."," end
	end

	str = str..")\n"

	return str
end

