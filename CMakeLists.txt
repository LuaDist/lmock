# Copyright (C) 2007-2012 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

project ( lmock NONE )
cmake_minimum_required ( VERSION 2.8 )
include ( cmake/dist.cmake )
include ( lua )

# Install all files and documentation
install_lua_module ( lmock src/lmock.lua )
install_lua_module ( luaunit src/luaunit.lua )
install_lua_module ( mock_env src/mock_env.lua )
install_lua_module ( mock_invoker src/mock_invoker.lua )
install_lua_module ( mock_method src/mock_method.lua )
install_data ( LICENSE.txt README.txt )
install_example ( sample.lua )
install_test ( ut/ )
