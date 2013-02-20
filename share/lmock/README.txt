		lmock by Wenhai Huang

lmock is a mock framework for lua , a toolkit for unit-test

You can download newest lmock from:
http://luaforge.net/projects/

if you have any problems, any suggestions, or find any bugs, you can mail to me.
you are welcom!
hwh008@gmail.com


**HOW TO INSTALL IT
run thie cmd in the shell:
make install
beware it is a local install, this means it install to ~/bin.
~/bin/lmock
~/bin/lua/lib/lmock


**HOW TO USE IT
first you write some test code like sample.lua, donot forget write down LuaUnit:run() at last line;
next step, save your test code to file, maybe called foo.lua;
then run this cmd in the shell:
lmock foo.lua






acknowledge
luaunit
******************************************************************
******************************************************************
		luaunit.lua  by Philippe Fremy

Luaunit is a testing framework for Lua, in the spirit of Extrem Programming.

Luaunit is derived from the initial work of Ryu Gwang but has evolved a lot
from the original code as my understanding of lua progressed.

Luaunit should work on all platforms supported by lua. It was tested on
Windows XP and Gentoo Linux.

Luaunit is used extensively in yzis (www.yzis.org), a vi clone, in order to
test the lua binding of the editor.

You can download luaunit from:
http://luaforge.net/projects/luaunit/


History:
========

v1.2: first public release

v1.3: ported to lua 5.1


