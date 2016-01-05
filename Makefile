CC=g++ -O3
OBJ_LINK= -fPIC -Wall -c
SHR_LINK = -shared
LIB=simplesocket++
VER=0.1-0
LIBNAME=lib$(LIB)
SRC_DIR=src
LIB_DIR=lib
BIN_DIR=bin
INC_DIR=include/ss++
PKG_DIR=debian
RM=rm -f
CP=cp -rf
LINK=ln -s
MKDIR=mkdir -p
RMDIR=rmdir
CLIENT=ClientSocket
SERVER=ServerSocket
SOCKET=Socket
EXCEPTION=SocketException
CLIENTAPP=simple_client_main
SERVERAPP=simple_server_main
TARGET=/usr
PKG_NAME=libsimplesocketpp
PACKAGE=$(PKG_NAME)-$(VER).deb

default: lib bin

all: lib bin package

install:
	$(CP) $(LIB_DIR)/$(LIBNAME).so.0.0 $(TARGET)/lib/
	$(CP) $(LIB_DIR)/$(LIBNAME).so.0 $(TARGET)/lib/
	$(CP) $(LIB_DIR)/$(LIBNAME).so $(TARGET)/lib/
	$(MKDIR) $(TARGET)/include/ss++
	$(CP) $(INC_DIR)/$(CLIENT).h $(TARGET)/include/ss++/
	$(CP) $(INC_DIR)/$(SERVER).h $(TARGET)/include/ss++/
	$(CP) $(INC_DIR)/$(SOCKET).h $(TARGET)/include/ss++/
	$(CP) $(INC_DIR)/$(EXCEPTION).h $(TARGET)/include/ss++/
#	$(CP) $(BIN_DIR)/$(CLIENTAPP) $(TARGET)/bin/
#	$(CP) $(BIN_DIR)/$(SERVERAPP) $(TARGET)/bin/

uninstall:
	$(RM) $(TARGET)/lib/$(LIBNAME).so.0.0
	$(RM) $(TARGET)/lib/$(LIBNAME).so.0
	$(RM) $(TARGET)/lib/$(LIBNAME).so
	$(RM) $(TARGET)/include/ss++/$(CLIENT).h
	$(RM) $(TARGET)/include/ss++/$(SERVER).h
	$(RM) $(TARGET)/include/ss++/$(SOCKET).h
	$(RM) $(TARGET)/include/ss++/$(EXCEPTION).h
	$(RMDIR) $(TARGET)/include/ss++
#	$(RM) $(TARGET)/bin/$(CLIENTAPP)
#	$(RM) $(TARGET)/bin/$(SERVERAPP)

package: lib
	$(MKDIR) $(PKG_DIR)/$(PKG_NAME)/$(TARGET)/lib
	$(MKDIR) $(PKG_DIR)/$(PKG_NAME)/$(TARGET)/include
	$(CP) $(LIB_DIR)/$(LIBNAME).so.0.0 $(PKG_DIR)/$(PKG_NAME)/$(TARGET)/lib/
	$(CP) $(INC_DIR) $(PKG_DIR)/$(PKG_NAME)/$(TARGET)/include
	dpkg-deb --build $(PKG_DIR)/$(PKG_NAME)
	mv $(PKG_DIR)/$(PKG_NAME).deb $(PKG_DIR)/$(PACKAGE)

lib_dir:
	mkdir -p $(LIB_DIR)

bin_dir:
	mkdir -p $(BIN_DIR)

lib: $(LIB_DIR)/$(LIBNAME).so

bin: $(BIN_DIR)/$(CLIENTAPP) $(BIN_DIR)/$(SERVERAPP)

$(LIB_DIR)/$(LIBNAME).so: $(SRC_DIR)/$(CLIENT).o $(SRC_DIR)/$(SERVER).o $(SRC_DIR)/$(SOCKET).o lib_dir
	$(CC) -fPIC -shared -I$(INC_DIR) -o $(LIB_DIR)/$(LIBNAME).so.0.0 $(SRC_DIR)/$(CLIENT).o $(SRC_DIR)/$(SERVER).o $(SRC_DIR)/$(SOCKET).o
	$(RM) $(LIB_DIR)/$(LIBNAME).so.0
	$(RM) $(LIB_DIR)/$(LIBNAME).so
	$(LINK) $(LIBNAME).so.0.0 $(LIB_DIR)/$(LIBNAME).so.0
	$(LINK) $(LIBNAME).so.0 $(LIB_DIR)/$(LIBNAME).so

$(SRC_DIR)/$(CLIENT).o: $(INC_DIR)/$(CLIENT).h $(SRC_DIR)/$(CLIENT).cpp
	$(CC) $(OBJ_LINK) -I$(INC_DIR) $(SRC_DIR)/$(CLIENT).cpp -o $(SRC_DIR)/$(CLIENT).o

$(SRC_DIR)/$(SERVER).o: $(INC_DIR)/$(SERVER).h $(SRC_DIR)/$(SERVER).cpp
	$(CC) $(OBJ_LINK) -I$(INC_DIR) $(SRC_DIR)/$(SERVER).cpp -o $(SRC_DIR)/$(SERVER).o

$(SRC_DIR)/$(SOCKET).o: $(INC_DIR)/$(SOCKET).h $(SRC_DIR)/$(SOCKET).cpp
	$(CC) $(OBJ_LINK) -I$(INC_DIR) $(SRC_DIR)/$(SOCKET).cpp -o $(SRC_DIR)/$(SOCKET).o

$(BIN_DIR)/$(CLIENTAPP): $(SRC_DIR)/$(CLIENTAPP).cpp bin_dir
	$(CC) -I$(INC_DIR) -L$(LIB_DIR) $(SRC_DIR)/$(CLIENTAPP).cpp -o $(BIN_DIR)/$(CLIENTAPP) -l$(LIB)

$(BIN_DIR)/$(SERVERAPP): $(SRC_DIR)/$(SERVERAPP).cpp bin_dir
	$(CC) -I$(INC_DIR) -L$(LIB_DIR) $(SRC_DIR)/$(SERVERAPP).cpp -o $(BIN_DIR)/$(SERVERAPP) -l$(LIB)

clean:
	$(RM) $(LIB_DIR)/$(LIBNAME).so.0.0
	$(RM) $(LIB_DIR)/$(LIBNAME).so.0
	$(RM) $(LIB_DIR)/$(LIBNAME).so
	$(RM) $(SRC_DIR)/$(CLIENT).o
	$(RM) $(SRC_DIR)/$(SERVER).o
	$(RM) $(SRC_DIR)/$(SOCKET).o
	$(RM) $(BIN_DIR)/$(CLIENTAPP)
	$(RM) $(BIN_DIR)/$(SERVERAPP)
	$(RM) -r $(PKG_DIR)/$(PKG_NAME)/$(TARGET)
	$(RM) $(PKG_DIR)/$(PACKAGE)

