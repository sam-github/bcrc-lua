
LUAPATHS=-I/usr/include/lua5.1
LUALIBS=-llua5.1
LUAFLAGS=-O2 -DNDEBUG -fPIC -fno-common -shared

prefix=/usr/local

build: bcrc.so

install: bcrc.so
	mkdir -p $(DESTDIR)$(prefix)/lib/lua/5.1/
	cp -v $< $(DESTDIR)$(prefix)/lib/lua/5.1/

bcrc.so: bcrc.cpp
	$(CXX) $(CFLAGS) $(LUAFLAGS) $(LUAPATHS) -o $@ $^ $(LDLIBS) $(LUALIBS)

README.txt: bcrc.cpp
	luadoc $< > $@

