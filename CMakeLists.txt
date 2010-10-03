# Copyright (C) 2007-2009 LuaDist.
# Created by Peter Kapec
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

PROJECT(lmock NONE)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
INCLUDE(dist.cmake)

# Install all files and documentation
INSTALL (DIRECTORY src/ DESTINATION ${INSTALL_LMOD})
INSTALL (FILES LICENSE.txt README.txt DESTINATION ${INSTALL_DATA})
INSTALL (FILES sample.lua DESTINATION ${INSTALL_EXAMPLE})
INSTALL (FILES run_sample.bat DESTINATION ${INSTALL_EXAMPLE})
INSTALL (FILES run_test.bat DESTINATION ${INSTALL_TEST})
INSTALL (DIRECTORY ut/ DESTINATION ${INSTALL_TEST})
