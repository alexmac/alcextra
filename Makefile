SDK=/path/to/alchemy/sdk
BUILD=$(PWD)/build
INSTALL=$(PWD)/install
SRCROOT=$(PWD)
THREADS=`sysctl -n hw.ncpu`
TRIPLE=avm2-unknown-freebsd8
PKG_CONFIG_PATH=$(SDK)/usr/lib/pkgconfig:$(INSTALL)/usr/lib/pkgconfig

ENV=PATH=$(SDK)/usr/bin:$(INSTALL)/usr/bin:$(PATH) PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) CC=gcc CXX=g++

all:
	mkdir -p $(BUILD)
	mkdir -p $(INSTALL)
	
	make ncurses
	make readline
	make libogg
	make libvorbis
	make freetype
	make sdlttf
	make physfs

	rm -f $(INSTALL)/usr/lib/*.la

.PHONY: physfs

clean:
	rm -rf $(BUILD)

physfs:
	rm -rf $(BUILD)/physfs
	mkdir -p $(BUILD)/physfs
	cd $(BUILD)/physfs && $(ENV) cmake -G "Unix Makefiles" -DCMAKE_PREFIX_PATH=$(SDK)/ $(SRCROOT)/physfs \
		-DCMAKE_INSTALL_PREFIX=$(INSTALL)/usr -DPHYSFS_BUILD_TEST=0 -DPHYSFS_HAVE_THREAD_SUPPORT=0 \
		-DPHYSFS_HAVE_CDROM_SUPPORT=0 -DPHYSFS_BUILD_STATIC=1 -DPHYSFS_BUILD_SHARED=0 -DPHYSFS_BUILD_PERL=0 \
		-DPHYSFS_BUILD_RUBY=0 -DOTHER_LDFLAGS=-lz -DPHYSFS_NO_64BIT_SUPPORT=1
	cd $(BUILD)/physfs && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install


ncurses:
	rm -rf $(BUILD)/ncurses
	mkdir -p $(BUILD)/ncurses
	cd $(BUILD)/ncurses && $(ENV) $(SRCROOT)/ncurses-5.9/configure --host=$(TRIPLE) --prefix=$(INSTALL)/usr \
		--enable-static --disable-shared --disable-pthread --without-shared --without-debug --without-tests \
		--without-progs --without-dlsym 
	cd $(BUILD)/ncurses && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

readline:
	rm -rf $(BUILD)/readline
	mkdir -p $(BUILD)/readline
	cd $(BUILD)/readline && $(ENV) $(SRCROOT)/readline-6.2/configure \
		--build=$(TRIPLE) --prefix=$(INSTALL)/usr --with-curses --enable-static --disable-shared --without-shared
	cd $(BUILD)/readline && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install-static

libogg:
	rm -rf $(BUILD)/libogg
	mkdir -p $(BUILD)/libogg
	cd $(BUILD)/libogg && $(ENV) $(SRCROOT)/libogg-1.3.0/configure \
		--host=$(TRIPLE) --prefix=$(INSTALL)/usr --enable-static --disable-shared
	cd $(BUILD)/libogg && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

libvorbis:
	rm -rf $(BUILD)/libvorbis
	mkdir -p $(BUILD)/libvorbis
	cd $(BUILD)/libvorbis && $(ENV) CC=gcc $(SRCROOT)/libvorbis-1.3.2/configure \
		--host=$(TRIPLE) --prefix=$(INSTALL)/usr --disable-oggtest --disable-examples \
		--disable-docs --enable-static --disable-shared
	cd $(BUILD)/libvorbis && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

sdlttf:
	rm -rf $(BUILD)/sdlttf
	mkdir -p $(BUILD)/sdlttf
	cd $(BUILD)/sdlttf && $(ENV) CC=gcc CXX=g++ $(SRCROOT)/SDL_ttf-2.0.10/configure \
		--build=$(TRIPLE) --prefix=$(INSTALL)/usr --with-freetype-prefix=$(INSTALL)/usr/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd $(BUILD)/sdlttf && $(ENV) CC=gcc CXX=g++ make -j$(THREADS) && make install
	rm -f $(SDK)/usr/lib/libSDL_ttf.a
	$(SDK)/usr/bin/ar crus $(INSTALL)/usr/lib/libSDL_ttf.a $(BUILD)/sdlttf/SDL_ttf.o

sdlimage:
	rm -rf $(BUILD)/sdlimage
	mkdir -p $(BUILD)/sdlimage
	cd $(BUILD)/sdlimage && $(ENV) CC=gcc CXX=g++ $(SRCROOT)/SDL_image-1.2.12/configure \
		--build=$(TRIPLE) --prefix=$(SDK)/usr --with-freetype-prefix=$(INSTALL)/usr/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd $(BUILD)/sdlimage && $(ENV) CC=gcc CXX=g++ make -j$(THREADS) && make install
	rm -f $(SDK)/usr/lib/libSDL_image.a
	$(SDK)/usr/bin/ar crus $(INSTALL)/usr/lib/libSDL_image.a $(BUILD)/sdlimage/*.o

sdlmixer:
	rm -rf $(BUILD)/sdlmixer
	mkdir -p $(BUILD)/sdlmixer
	cd $(BUILD)/sdlmixer && $(ENV) CC=gcc CXX=g++ $(SRCROOT)/SDL_mixer-1.2.12/configure \
		--build=$(TRIPLE) --prefix=$(INSTALL)/usr --with-freetype-prefix=$(INSTALL)/usr/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd $(BUILD)/sdlmixer && $(ENV) CC=gcc CXX=g++ make -j$(THREADS) && make install
	rm -f $(SDK)/usr/lib/libSDL_mixer.a
	$(SDK)/usr/bin/ar crus $(INSTALL)/usr/lib/libSDL_mixer.a $(BUILD)/sdlmixer/build/*.o

freetype:
	rm -rf $(BUILD)/freetype
	mkdir -p $(BUILD)/freetype
	cd $(BUILD)/freetype && $(ENV) CC=gcc CXX=g++ $(SRCROOT)/freetype-2.4.8/configure --build=$(TRIPLE) \
		--without-bzip2 --without-ats --without-old-mac-fonts --disable-mmap --enable-static --disable-shared --prefix=$(INSTALL)/usr
	cd $(BUILD)/freetype && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install
