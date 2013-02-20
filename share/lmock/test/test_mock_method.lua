--require"lmock"
--require"mock_method"
--require"luaunit"

TestMockMethod = {}

function TestMockMethod:testSuccessOnceCallWithMoreParamAndReturn()
	local method = lmock.CMockMethod.new( "foo" )

	method:expects( lmock.once() )
		:with( lmock.eq(5) , lmock.eq("god") )
		:will( "dam" , 23 )

	method:expects( lmock.once() )
		:with( lmock.eq("god") , lmock.eq(5) )
		:will( 23 , "dam" )
	
	local a , b = method:call( 5 , "god" )
	assert_equals( a , "dam" )
	assert_equals( b , 23 )

	a , b = method:call( "god" , 5 )
	assert_equals( a , 23 )
	assert_equals( b , "dam" )

	assert_equals( method:verify() , false )
end


function TestMockMethod:testFailWithNotEnoughCall()
	local method = lmock.CMockMethod.new( "foo" )

	method:expects( lmock.once() )
	method:expects( lmock.once() )

	method:verify()
end

function TestMockMethod:testFailWithErrorParam()
	local method = lmock.CMockMethod.new( "foo" )

	method:expects( lmock.once() ):with( lmock.eq(1) )
	method:expects( lmock.once() ):with( lmock.eq(2) )

	assert_error( method.call , method , 10 )
	assert_error( method.call , method , 20 )

	assert( method:verify() )
end

function TestMockMethod:testFailWithOverloadCall()
	local method = lmock.CMockMethod.new( "foo" )

	method:expects( lmock.once() )

	method:call()
	assert_error( method.call , method )

	assert( not method:verify() )
end