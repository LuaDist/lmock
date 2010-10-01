@echo off
set LUA_PATH=.\?.lua;.\src\?.lua
lua -llmock ut/test_main.lua
