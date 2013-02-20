--require"mock_invoker"
--require"luaunit"
--require"lmock"

TestMockInvoker = {}

function TestMockInvoker:testUpdateInvokerOnceRestrict()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	assert_equals( invoker:updateRestrict() , false )
end

function TestMockInvoker:testSetupInvokerWithParam()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	invoker:with( lmock.eq( 4 ) )
end

function TestMockInvoker:testSetupInvokerWithParamAndReturn()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	invoker:with( lmock.eq( 4 ) )
		:will( 9 )
end

function TestMockInvoker:testSetupInvokerWithMoreParamAndMoreReturn()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	invoker:with( lmock.eq( 4 ) , lmock.eq( 8 ) )
		:will( 14 , 28 )
end

function TestMockInvoker:testExcuteWithoutAnything()
	local invoker = lmock.CMockInvoker.new( lmock.once() )
	assert_equals( #invoker:excute() , 0 )
end

function TestMockInvoker:testExcuteWithParam()
	local invoker = lmock.CMockInvoker.new( lmock.once() )

	invoker:with( lmock.eq( 3 ) )
	assert_equals( #invoker:excute( 3 ) , 0 )

	invoker:with( lmock.eq(32) , lmock.eq(67) )
	assert_equals( #invoker:excute( 32 , 67 ) , 0 )

	invoker:with( lmock.eq("param") )
	assert_equals( #invoker:excute( "param" ) , 0 )
end

function TestMockInvoker:testExcuteWithParamAndReturn()
	local invoker = lmock.CMockInvoker.new( lmock.once() )

	invoker:with( lmock.eq(5) )
		:will( 9 )
	assert_equals( unpack(invoker:excute( 5 )) , 9 )

	invoker:with( lmock.eq(5) , lmock.eq(7) )
		:will( 99 )
	assert_equals( unpack(invoker:excute( 5 , 7 )) , 99 )

	invoker:with( lmock.eq("god" ) )
		:will( "dam" )
	assert_equals( unpack(invoker:excute( "god" )) , "dam" )

	invoker:with( lmock.eq( "god" ) , lmock.eq(5) )
		:will( 77 , "dam" )
	local a , b = unpack(invoker:excute( "god" , 5 ))
	assert_equals( a , 77 )
	assert_equals( b , "dam" )

end

function TestMockInvoker:testExcuteWithMoreReturn()
	local invoker = lmock.CMockInvoker.new( lmock.once() )

	invoker:will( 9 , "dam" , 24 , "asshole" )

	local a , b , c , d = unpack( invoker:excute() )
	assert_equals( a , 9 )
	assert_equals( b , "dam" )
	assert_equals( c , 24 )
	assert_equals( d , "asshole" )

end

function TestMockInvoker:testExcuteWithoutReturn()
	local invoker = lmock.CMockInvoker.new( lmock.once() )

	invoker:with( lmock.eq(4) , lmock.eq("god") )

	assert_equals( #invoker:excute( 4 , "god" ) , 0 )

end

