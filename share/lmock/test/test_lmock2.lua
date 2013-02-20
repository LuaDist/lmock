--require"luaunit"
--require"lmock"

mod1 = {
	mod2 = {
		foo = function () error"asshole" end , 
		foo2 = function () error"asshole2" end
	} , 
	foo = function () error"dam" end ,
	foo2 = function () error"dam2" end
}

Testlmock2 = {}

function Testlmock2:testCallModuleMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
		:with( lmock.eq(54) , lmock.eq("hwh") )
		:will( 4488 , "god" )

	local a , b = mod1.mod2.foo( 54 , "hwh" )
	assert_equals( a , 4488 )
	assert_equals( b , "god" )

	mock:verify()
end

function Testlmock2:testFailWithErrorParam()
	local mock = lmock.create()
	
	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
		:with( lmock.eq(2) , lmock.eq("dam") )
		:will( 33 )

	assert_error( mod1.mod2.foo , 3 , "uvw" )

	assert_error( mock.verify , mock )
end

function Testlmock2:testMoreCallModuleMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )

	mod1.mod2.foo()
	mod1.mod2.foo()

	mock:verify()
end

function Testlmock2:testFailWithOverloadCallModuleMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )

	mod1.mod2.foo()
	mod1.mod2.foo()
	assert_error( mod1.mod2.foo )

	mock:verify()
end

function Testlmock2:testFailWithNotEnoughCallModuleMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )

	mod1.mod2.foo()
	
	assert_error( mock.verify , mock )	
end

function Testlmock2:testCallMemberMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2:foo" )
		:expects( lmock.once() )
		:with( lmock.eq(3) , lmock.eq(1) )
		:will( 7 )
	
	assert_equals( mod1.mod2:foo( 3 , 1 ) , 7 )

	mock:verify()
end

function Testlmock2:testFailWithOverloadCallMemberMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2:foo" )
		:expects( lmock.once() )
	
	mod1.mod2:foo()
	assert_error( mod1.mod2.foo , mod1.mod2 )

	mock:verify()
end

function Testlmock2:testFailWithNotEnoughCallMemberMethod()
	local mock = lmock.create()

	mock:method( "mod1.mod2:foo" )
		:expects( lmock.once() )
	
	assert_error( mock.verify , mock )
end

function Testlmock2:testCreateModuleMethodNotChangeG()
	assert_error( mod1.mod2.foo )
	assert_error( mod1.mod2.foo2 )

	local mock = lmock.create()

	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
		:will( 77 )

	mock:method( "mod1.mod2:foo2" )
		:expects( lmock.once() )
		:will( "lua" )

	assert_equals( mod1.mod2.foo() , 77 )
	assert_equals( mod1.mod2:foo2() , "lua" )

	mock:verify()

	setfenv( 1 , _G )
	assert_error( mod1.mod2.foo )
	assert_error( mod1.mod2.foo2 )
end

function Testlmock2:testCreateModuleMethodNotChangeG2()
	assert_error( mod1.foo )
	assert_error( mod1.foo2 )
	
	local mock = lmock.create()
	
	mock:method( "mod1.foo" )
		:expects( lmock.once() )
		
	mock:method( "mod1:foo2" )
		:expects( lmock.once() )
		
	mod1.foo()
	mod1:foo2()
	mock:verify()
	
	setfenv( 1 , _G )
	assert_error( mod1.foo )
	assert_error( mod1.foo2 )
end

function Testlmock2:testCreateModuleMethodNotChangeG3()
	assert_error( mod1.foo )
	assert_error( mod1.foo2 )
	
	local mock = lmock.create()
	
	mock:method( "mod1:foo2" )
		:expects( lmock.once() )
			
	mock:method( "mod1.foo" )
		:expects( lmock.once() )
		
	mod1.foo()
	mod1:foo2()
	mock:verify()
	
	setfenv( 1 , _G )
	assert_error( mod1.foo )
	assert_error( mod1.foo2 )
end

function Testlmock2:testFailWithUnExistMethod()
	local mock = lmock.create()
	
	assert_error( mock.method , mock , "unexist_method" , true )
	assert_error( mock.method , mock , "unmod.unmod.unmod.unexist_method" , true )
	assert_error( mock.method , mock , "unmod.unmod.unmod.un:unexist_method" , true )
end

function Testlmock2:test4CallWith4Method()
	local mock = lmock.create()
	
	mock:method( "mod1.foo" )
		:expects( lmock.once() )
		:will(7)
	
	mock:method( "mod1.foo" )
		:expects( lmock.once() )
		:will(8)
		
	mock:method( "mod1:foo2" )
		:expects( lmock.once() )
		:will(9)
		
	mock:method( "mod1:foo2" )
		:expects( lmock.once() )
		:will(10)
		
	mock:method( "mod1.mod2.foo" )
		:expects( lmock.once() )
		:will(11)
		
	mock:method( "mod1.mod2:foo2" )
		:expects( lmock.once() )
		:will(12)
		
	mock:method( "mod1.mod2:foo2" )
		:expects( lmock.once() )
		:will(13)
		
	assert_equals( mod1.foo() , 7 )
	assert_equals( mod1.foo() , 8 )
	assert_equals( mod1:foo2() , 9 )
	assert_equals( mod1:foo2() , 10 )
	assert_equals( mod1.mod2.foo() , 11 )
	assert_equals( mod1.mod2:foo2() , 12 )
	assert_equals( mod1.mod2:foo2() , 13 )
	
	mock:verify()
	
	setfenv( 1 , _G )
	assert_error( mod1.foo )
	assert_error( mod1.foo2 )
	assert_error( mod1.mod2.foo )
	assert_error( mod1.mod2.foo2 )
end