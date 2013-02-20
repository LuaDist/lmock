--require"luaunit"
--require"lmock"

Testlmock4 = {}

function Testlmock4:testOutOrderButMatchParamOnCall()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx( 3 ) , lmock.eq( 5 ) )
		:will( 15 )
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx( 5 ) , lmock.eq( 3 ) )
		:will( 151 )

	assert_equals( 151 , foo( 5 , 3 ) )
	assert_equals( 15 , foo( 3 , 5 ) )
	mock:verify()
end

function Testlmock4:testInvokerParameterMatch()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	invoker:with( lmock.eq( 4 ) , lmock.eqx( "lua" ) , lmock.eqx( 53 ) )

	assert( invoker:matchParameter( 4 , "lua" , 53 ) )
	assert( not invoker:matchParameter( 4 , "lua " , 53 ) )
	assert( not invoker:matchParameter( 3 , "lua" , 53 ) )
	assert( not invoker:matchParameter( 4 , "lua" , 50 ) )

	assert( not invoker:matchParameter( 4 ) )
	assert( invoker:matchParameter( 4 , "lua" , 53 , 55 ) )
end

function Testlmock4:testInvokerParameterMatchWithoutParam()
	local invoker = lmock.CMockInvoker.new( lmock.once() )

	assert( invoker:matchParameter() )
	assert( invoker:matchParameter( 1 ) )
end

function Testlmock4:testMethodPrintParameterError()
	local method = lmock.CMockMethod.new( "foo" )
	method:expects( lmock.once() )
		:with( lmock.eq( 4 ) , lmock.eq( 8 ) )
		:will( 10 , "lua" )
	method:expects( lmock.exactly( 2 ) )
		:with( lmock.eq( "lua" ) )
		:will( "good" )
	method:default()
		:will( "lua" )
	
	assert_error( method.printParameterError , 10 )
end

function Testlmock4:testInvokerToString()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	invoker:with( lmock.eq( 2 ) , lmock.eq( "lua" ) )
		:will( 10 , "good" )
	local str = 
[[  :expects(lmock.once())
  :invoke(0)
  :with(lmock.eq(2),lmock.eq("lua"))
  :will(10,"good")
]]
	assert_equals( invoker:toString() , str )

	invoker:updateRestrict()
	str = 
[[  :expects(lmock.once())
  :invoke(1)
  :with(lmock.eq(2),lmock.eq("lua"))
  :will(10,"good")
]]
	assert_equals( str , invoker:toString() )
end

function Testlmock4:testOnce()
	local once = lmock.once()

	assert_equals( 
[[  :expects(lmock.once())
  :invoke(0)
]] , once:toString() )

	assert( once:validate() )
	assert( not once:update() )
	assert( not once:validate() )

	assert_equals( 
[[  :expects(lmock.once())
  :invoke(1)
]] , once:toString() )
end

function Testlmock4:testExactly()
	local r = lmock.exactly( 3 )

	assert_equals( 
[[  :expects(lmock.exactly(3))
  :invoke(0)
]], r:toString() )

	assert( r:validate() )
	assert( r:update() )
	assert( r:validate() )
	assert( r:update() )
	assert( r:validate() )
	assert( not r:update() )
	assert( not r:validate() )

	assert_equals( 
[[  :expects(lmock.exactly(3))
  :invoke(3)
]], r:toString() )
end

function Testlmock4:testRange()
	local r = lmock.range( 1 , 2 )
	
	assert_equals( 
[[  :expects(lmock.range(1,2))
  :invoke(0)
]] , r:toString() )

	assert( r:validate() )
	assert( r:update() )
	assert( not r:validate() )
	assert( not r:update() )
	assert( not r:validate() )

	assert_equals( 
[[  :expects(lmock.range(1,2))
  :invoke(2)
]] , r:toString() )
end

function Testlmock4:testEq()
	local eq = lmock.eq( 5 )
	assert_equals( eq:test( 10 ) , false )
	assert_equals( true , eq:test( 5 ) )
	assert_equals( "lmock.eq(5)" , eq:toString() )

	eq = lmock.eq( "lua" )
	assert_equals( false , eq:test( "ooxx" ) )
	assert_equals( true , eq:test( "lua" ) )
	assert_equals( "lmock.eq(\"lua\")" , eq:toString() )
end

function Testlmock4:testAny()
	local any = lmock.any()
	assert_equals( true , any:test( 4 ) )
	assert_equals( "lmock.any()" , any:toString() )
end

function Testlmock4:testNeverExpect()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.never() )
		:with( lmock.eq(4) )
	mock:method( "foo" )
		:default()
		:with( lmock.eq(5) )

	foo(5)
	assert_error( foo , 4 )
	mock:verify()
end

function Testlmock4:testNeverObj()
	local r = lmock.never()
	
	assert( not r:validate() )
	assert_equals( r:toString() , "  :expects(lmock.never())\n" )
	local rst , err = pcall( r.update , r )
	assert( not rst )
	assert_equals( err , "Invocation should never invoked\n" )
end

function Testlmock4:testStubsMethod()
	local mock = lmock.create()

	mock:method( "foo" )
		:stubs()
		:with( lmock.eq( 4 ) )
		:will( 10 )

	assert_equals( foo( 4 ) , 10 )
	assert_equals( foo( 4 ) , 10 )
	assert_equals( foo( 4 ) , 10 )

	mock:verify()
end