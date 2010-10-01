BIN_PATH=~/bin/
SRC_PATH=~/bin/lua/
CP=cp -a

install:
	if ! test -d $(BIN_PATH); then mkdir $(BIN_PATH); fi
	if ! test -d $(SRC_PATH); then mkdir $(SRC_PATH); fi
	$(CP) lmock $(BIN_PATH)
	$(CP) src $(SRC_PATH)lmock
