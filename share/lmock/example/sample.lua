

function foo( a ) error() end

function myFunc( a , b )
	foo( a )
	if type(a) == "number" then
		foo("rebmun")
	end
	if type(a) == "string" then
		foo(b)
	end
	return foo( b , a )
end

TestSample = {}

function TestSample:testMyFuncShouldInvokeFoo3Times()
	local mock = lmock.create()
	
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx(3) )
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx("rebmun") )
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx(5) , lmock.eqx(3) )
		:will( 15 )
		
	local rst = mock:run( myFunc , 3 , 5 )
	assert_equals( rst , 15 )
	mock:verify()
end

function TestSample:testMyFuncShowInvokeDefaultFoo()
	local mock = lmock.create()
	
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx(3) )
	mock:method( "foo" )
		:default()
		:will(0)
		
	local rst = mock:run( myFunc , 3 )
	assert_equals( rst , 0 )
	mock:verify()
end

function TestSample:testMyFuncShouldInvokeFooExactly2TimesWithSameParam()
	local mock = lmock.create()
	
	mock:method( "foo" )
		:expects( lmock.exactly(2) )
		:with( lmock.eqx"lua" )
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx"lua" , lmock.any() )
		:will( "lua is great" )
	
	local rst = mock:run( myFunc , "lua" , "lua" )
	assert_equals( rst , "lua is great" )
	mock:verify()
end

function TestSample:testMyFuncShouldInvokeFooAtLeast2Times()
	local mock = lmock.create()
	
	mock:method( "foo" )
		:expects( lmock.range( 2 , 3 ) )
		:with( lmock.any() , lmock.any() )
		:will( 0 )
		
	local rst = mock:run( myFunc )
	assert_equals( rst , 0 )
	mock:verify()
end

function TestSample:testMyFuncFailWithErrorArgument()
	local mock = lmock.create()
	
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eqx(3) )
	
	local rst = mock:run( myFunc , 5 )
	assert_equals( rst , nil )
	mock:verify()
end

function TestSample:testMyFuncFailWithNotEnoughCall()
	local mock = lmock.create()
	
	mock:method( "foo" )
		:expects( lmock.exactly(3) )
	
	local rst = mock:run( myFunc , {} )
	assert_equals( rst , nil )
	mock:verify()
end

function TestSample:testMyFuncFailWithInvokeDisabled()
	local mock = lmock.create()

	mock:method( "foo" )
		:expects( lmock.never() )
		:with( lmock.eq( 3 ) )

	mock:run( myFunc , 3 )
	mock:verify()
end

function TestSample:testMyFunctionWithStubMethod()
	local mock = lmock.create()

	mock:method( "foo" )
		:stubs()
		:with( lmock.eq("lua") , lmock.eq("lua") )
		:will( 10 )

	mock:method( "foo" )
		:stubs()
		:with( lmock.eq("lua" ) )
	
	assert_equals( mock:run( myFunc , "lua" , "lua" ) , 10 )
	mock:verify()
end

LuaUnit:run()
