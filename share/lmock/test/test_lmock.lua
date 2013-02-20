
--require"luaunit"
--require"lmock"

function foo() end
function foo1() end
function foo2() end
function foo3() end

Testlmock = {}

function Testlmock:setUp()
	--print"Testlmock:setUp"
end

function Testlmock:tearDown()
	--print"Testlmock:tearDown"
end

function Testlmock:testSetTempEnvAfterCreateMock()
	lmock.create()

	a = 5
	_G.a = 5
	assert_equals( a , 5 )
	assert_equals( _G.a , 5 )

	a = 8
	assert_equals( a , 8 )
	assert_equals( _G.a , 5 )

	_G.a = 11
	assert_equals( a , 8 )
	assert_equals( _G.a , 11 )

	a = 35
	_G.a = 46
	assert_equals( a , 35 )
	assert_equals( _G.a , 46 )

	setfenv( 1 , _G )
	assert_equals( a , 46 )
end

function Testlmock:testMockCreateMethod()
	local mock = lmock.create()
	mock:method( "foo" )

	assert_equals( type(foo) , "function" )

	mock:method( "foo2" )
	assert_equals( type(foo2) , "function" )
	assert_equals( type(foo) , "function" )
	assert( foo ~= foo2 )

	local oldFoo = foo
	mock:method( "foo" )
	assert_equals( type(foo) , "function" )
	assert_equals( oldFoo , foo )
	assert( foo ~= foo2 )
end

function Testlmock:testCheckMockMethodInvokeOnce()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.once() )

	foo()

	mock:verify()
end

function Testlmock:testFailCheckMockMethodNotInvokeOnce()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.once() )
	
	assert_error( mock.verify , mock )
end

function Testlmock:testMockOnceSuccess()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eq( 4 ) , lmock.eq( 8 ) )
		:will( 10 )
	
	assert_equals( foo( 4 , 8 ) , 10 )

	mock:verify()
end

function foobar( a )
	error( "the mock donot replace origin function , asshole" )
end

function Testlmock:testMockCanReplaceTheGlobalFunction()
	local mock = lmock.create()
	mock:method( "foobar" )
		:expects( lmock.once() )
		:with( lmock.eq("bar") )
		:will( 55 )
	
	assert_equals( foobar( "bar" ) , 55 )

	mock:verify()
end


function Testlmock:testMoreMethodWorkTogether()
	local mock = lmock.create()
	mock:method( "foo1" )
		:expects( lmock.once() )
		:with( lmock.eq(5) )
		:will( 25 )
	
	mock:method( "foo2" )
		:expects( lmock.once() )
		:with( lmock.eq( "god" ) )
		:will( "dam" )

	mock:method( "foo3" )
		:expects( lmock.once() )
		:with( lmock.eq( 87 ) , lmock.eq( "god" ) )
		:will( "dam11" )

	assert_equals( foo1( 5 ) , 25 )
	assert_equals( foo2( "god" ) , "dam" )
	assert_equals( foo3( 87 , "god" ) , "dam11" )

	mock:verify()
end

function Testlmock:testMockWithMoreReturn()
	local mock = lmock.create()
	mock:method( "foo" )
		:expects( lmock.once() )
		:with( lmock.eq(4) , lmock.eq("god") )
		:will( 87 , "dam" )
	
	local a , b = foo( 4 , "god" )
	assert_equals( a , 87 )
	assert_equals( b , "dam" )

	mock:verify()
end

function Testlmock:testOkWithOneMethodMoreCall()
	assert_error( foobar )

	local mock = lmock.create()
	mock:method( "foobar" )
		:expects( lmock.once() )
		:with( lmock.eq("pixel") )
		:will( 10 , "a" )

	mock:method( "foobar" )
		:expects( lmock.once() )
		:with( lmock.eq(5) , lmock.eq(9) )
		:will( "hwh" )
	
	local a , b = foobar"pixel"
	assert_equals( a , 10 )
	assert_equals( b , "a" )

	assert_equals( foobar( 5 , 9 ) , "hwh" )

	mock:verify()
end

function Testlmock:testOkWithMoreMethodMoreCall()
	local mock = lmock.create()
	
	mock:method( "foo1" )
		:expects( lmock.once() )
		:with( lmock.eq(4) )
		:will( 82 )
		
	mock:method( "foo1" )
		:expects( lmock.once() )
		:with( lmock.eq("pixel") )
		:will( "www.g.cn" )
		
	mock:method( "foo2" )
		:expects( lmock.once() )
		:with( lmock.eq(89) )
		:will( "god" )
		
	mock:method( "foo3" )
		:expects( lmock.once() )
		:with( lmock.eq(7) )
		:will( 49 )
		
	mock:method( "foo3" )
		:expects( lmock.once() )
		:with( lmock.eq(8) )
		:will( 64 )
		
	mock:method( "foo3" )
		:expects( lmock.once() )
		:with( lmock.eq(9) )
		:will( 81 )
	
	assert_equals( foo1(4) , 82 )
	assert_equals( foo2(89) , "god" )
	assert_equals( foo3(7) , 49 )
	assert_equals( foo3(8) , 64 )
	assert_equals( foo1("pixel") , "www.g.cn" )
	assert_equals( foo3(9) , 81 )
	
	mock:verify()
end

function Testlmock:testFailWithNotEnoughCall()
	local mock = lmock.create()
	
	mock:method( "foo1" )
		:expects( lmock.once() )
		
	mock:method( "foo2" )
		:expects( lmock.once() )
	
	mock:method( "foo2" )
		:expects( lmock.once() )
		
	foo2()
	foo1()
	
	assert_error( mock.verify , mock )
end

function Testlmock:testFailWithOverloadCall()
	local mock = lmock.create()
	
	mock:method( "foo1" )
		:expects( lmock.once() )
		
	mock:method( "foo2" )
		:expects( lmock.once() )
		
	mock:method( "foo2" )
		:expects( lmock.once() )
	
	foo2()
	foo1()
	foo2()
	assert_error( foo2 )
	
	mock:verify()
end

function foobar1( a , b )
	error( "asshole" )
end

function foobar2( a )
	error( "dam" )
end

function invoke_foobar( a , b )
	foobar2( a )
	foobar1( a , b )
	return foobar2( b )
end

function Testlmock:testSetTesteeFunctionEnv()
	local mock = lmock.create()
	
	mock:method( "foobar1" )
		:expects( lmock.once() )
		:with( lmock.eq(1) , lmock.eq("hello") )
	
	mock:method( "foobar2" )
		:expects( lmock.once() )
		:with( lmock.eq(1) )
		
	mock:method( "foobar2" )
		:expects( lmock.once() )
		:with( lmock.eq("hello") )
		:will( 10 )
		
	assert_equals( mock:run( invoke_foobar , 1 , "hello" ) , 10 )
	
	mock:verify()

	assert_error( invoke_foobar )
end

function foo() error"asshole foo" end

function Testlmock:testCreateMethodNotChangeG()
	assert_error( foo )

	local mock = lmock.create()

	mock:method( "foo" )
		:expects( lmock.once() )
	
	foo()

	mock:verify()
	
	local oldFoo = foo
	setfenv( 1 , _G )
	assert_error( foo )
	assert( oldFoo ~= foo )
end
