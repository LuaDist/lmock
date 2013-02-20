
Testlmock5 = {}

function Testlmock5:testUnderlineMethodNameParseOk()
	local mock = lmock.create()
	
	mock:method( "_m1._func1" , false )
		:expects( lmock.once() )
		:will( 100 )
	assertEquals( 100 , _m1._func1() )
	
	mock:method( "_._" )
		:expects( lmock.once() )
		:will( 3 )
	assertEquals( 3 , _._() )
	
	mock:method( "m__9.func___a1a" )
		:expects( lmock.once() )
		:will( 1 )
	assertEquals( 1 , m__9.func___a1a() )
	
	mock:method( "__m1.func0_5" )
		:expects( lmock.once() )
		:will( "mod" )
	assertEquals( "mod" , __m1.func0_5() )
	
	mock:verify()
end
