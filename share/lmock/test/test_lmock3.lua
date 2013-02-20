--require"luaunit"
--require"lmock"

aa = {
	b = {
		c = "lua"
	}
}

Testlmock3 = {}

function Testlmock3:testVarABCInMockEnv()
	assert_equals( aa.b.c , "lua" )
	assert_equals( uu , nil )

	local mock = lmock.create()

	assert_equals( aa.b.c , "lua" )
	assert_equals( uu , nil )
	aa = {
		b = {
		}
	}
	aa.b.c = "ass"
	uu = {
		v = {
			w = "hole"
		}
	}
	assert_equals( aa.b.c , "ass" )
	assert_equals( uu.v.w , "hole" )

	assert_equals( _G.aa.b.c , "lua" )
	assert_equals( _G.uu , nil )

	setfenv( 1 , _G )
	assert_equals( aa.b.c , "lua" )
	assert_equals( uu , nil )
end

function doSomething()
	foo( 3 , 4 )
	mod1.foo( "lua" )
	mod1:foo2( "is" )
	mod1.mod2.foo( "good" )
	return mod1.mod2:foo2( "hello" , "lua" )
end

function Testlmock3:testMethodWithAnyMockCallOk()
	local mock = lmock.create()

	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eq(3) , lmock.eq(4) )
	mock:method( "mod1.foo" )
		:expects( lmock.once() )
		:with( lmock.eq("lua") )
	mock:method( "mod1:foo2" )
		:expects( lmock.once() )
		:with( lmock.eq("is") )
	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
		:with( lmock.eq("good") )
	mock:method( "mod1.mod2:foo2" )
		:expects( lmock.once() )
		:with( lmock.eq("hello") , lmock.eq("lua") )
		:will( 100 )
	
	assert_equals( mock:run( doSomething ) , 100 )
	mock:verify()
	assert_error( doSomething )
end

function Testlmock3:testMethodWithDefaultCanCallMoreTimes()
	local mock = lmock.create()

	mock:method( "mod1.foo" )
		:default()

	mod1.foo()
	mod1.foo()
	mod1.foo()
	mock:verify()
end


function Testlmock3:testCallDefaultWithErrorParam()
	local mock = lmock.create()

	mock:method( "mod1.foo" )
		:default()
		:with( lmock.eq(7) , lmock.eq(8) )
		:will( 10 )
	
	assert_error( mod1.foo , 1 , 2 )
	assert_error( mod1.foo )
	assert_equals( mod1.foo( 7 , 8 ) , 10 )
	mock:verify()
end


function Testlmock3:testAnyParamInMethod()
	local mock = lmock.create()

	mock:method( "mod1:foo" )
		:default()
		:with( lmock.eqx(10) , lmock.any() , lmock.any() )

	mod1:foo( 10 , 10 , 10 )
	mod1:foo( 10 )
	mod1:foo( 10 , "ak" , "cn" )

	mock:verify()
end

function Testlmock3:testExactlyCallOk()
	local mock = lmock.create()
	
	mock:method( "mod1.foo" )
		:expects( lmock.exactly( 3 ) )
		:with( lmock.eqx(1) , lmock.eqx(2) )
		:will( 10 )
		
	assert_equals( mod1.foo( 1 , 2 ) , 10 )
	assert_equals( mod1.foo( 1 , 2 ) , 10 )
	assert_equals( mod1.foo( 1 , 2 ) , 10 )
	
	mock:verify()
end

function Testlmock3:testFailWithNotEnoughCallInExactly()
	local mock = lmock.create()
	
	mock:method( "mod1.foo" )
		:expects( lmock.exactly( 3 ) )
		:with( lmock.eqx(1) , lmock.eqx(2) )
		:will( 10 )
		
	assert_equals( mod1.foo( 1 , 2 ) , 10 )
	assert_error( mock.verify , mock )
end

function Testlmock3:testRangeCallOk()
	local mock = lmock.create()
	
	mock:method( "mod1.foo" )
		:expects( lmock.range( 1 , 3 ) )
		:with( lmock.eq(1) )
		:will( 10 )
		
	mock:method( "mod1.foo2" )
		:expects( lmock.range( 2 , 3 ) )
		:with( lmock.eq(4) )
		:will( 8 )
		
	mod1.foo2(4)	
	mod1.foo(1)
	mod1.foo2(4)

	mock:verify()	
end

function Testlmock3:testRangeWithNotEnoughCall()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.range( 2 , 3 ) )
	
	foo()
	
	assert_error( mock.verify , mock )
end