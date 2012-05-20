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

	@if [ -d $(SDK)/usr/bin ] ; then true ; \
		else echo "Couldn't locate Alchemy sdk directory, please invoke make with \"make SDK=/path/to/alchemy/sdk ...\"" ; exit 1 ; \
	fi	
	
	make ncurses
	make readline
	make libogg
	make libvorbis
	make libtiff
	make libwebp
	make freetype
	make sdlttf
	make sdlmixer
	make sdlimage
	make physfs
	make aalib

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

aalib:
	rm -rf $(BUILD)/aalib
	mkdir -p $(BUILD)/aalib
	cd $(BUILD)/aalib && $(ENV) $(SRCROOT)/aalib-1.4.0/configure --host=$(TRIPLE) --prefix=$(INSTALL)/usr \
		--enable-static --disable-shared --without-x --with-curses-driver=no
	cd $(BUILD)/aalib && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

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
	cd $(BUILD)/libvorbis && $(ENV) $(SRCROOT)/libvorbis-1.3.2/configure \
		--host=$(TRIPLE) --prefix=$(INSTALL)/usr --disable-oggtest --disable-examples \
		--disable-docs --enable-static --disable-shared
	cd $(BUILD)/libvorbis && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

libtiff:
	rm -rf $(BUILD)/libtiff
	mkdir -p $(BUILD)/libtiff
	cd $(BUILD)/libtiff && $(ENV) $(SRCROOT)/tiff-4.0.1/configure \
		--host=$(TRIPLE) --prefix=$(INSTALL)/usr --enable-static --disable-shared
	cd $(BUILD)/libtiff && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

libwebp:
	rm -rf $(BUILD)/libwebp
	mkdir -p $(BUILD)/libwebp
	cd $(BUILD)/libwebp && $(ENV) $(SRCROOT)/libwebp-0.1.3/configure \
		--host=$(TRIPLE) --prefix=$(INSTALL)/usr --enable-static --disable-shared
	cd $(BUILD)/libwebp && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

xz:
	rm -rf $(BUILD)/xz
	mkdir -p $(BUILD)/xz
	cd $(BUILD)/xz && $(ENV) $(SRCROOT)/xz-5.0.3/configure \
		--host=$(TRIPLE) --prefix=$(INSTALL)/usr --enable-static --disable-shared \
		--enable-encoders=lzma1,lzma2,delta --enable-decoders=lzma1,lzma2,delta --disable-assembler \
		--disable-threads
	cd $(BUILD)/xz && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install

sdlttf:
	rm -rf $(BUILD)/sdlttf
	mkdir -p $(BUILD)/sdlttf
	cd $(BUILD)/sdlttf && $(ENV) $(SRCROOT)/SDL_ttf-2.0.10/configure \
		--build=$(TRIPLE) --prefix=$(INSTALL)/usr --with-freetype-prefix=$(INSTALL)/usr/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd $(BUILD)/sdlttf && $(ENV) make -j$(THREADS) && make install
	rm -f $(INSTALL)/usr/lib/libSDL_ttf.a
	$(SDK)/usr/bin/ar crus $(INSTALL)/usr/lib/libSDL_ttf.a $(BUILD)/sdlttf/SDL_ttf.o

sdlimage:
	rm -rf $(BUILD)/sdlimage
	mkdir -p $(BUILD)/sdlimage
	cd $(BUILD)/sdlimage && $(ENV) LIBPNG_CFLAGS="" LIBPNG_LIBS=-lpng $(SRCROOT)/SDL_image-1.2.12/configure \
		--build=$(TRIPLE) --prefix=$(INSTALL)/usr --with-freetype-prefix=$(INSTALL)/usr/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd $(BUILD)/sdlimage && $(ENV) make -j$(THREADS) && make install
	rm -f $(INSTALL)/usr/lib/libSDL_image.a
	$(SDK)/usr/bin/ar crus $(INSTALL)/usr/lib/libSDL_image.a $(BUILD)/sdlimage/*.o

sdlmixer:
	rm -rf $(BUILD)/sdlmixer
	mkdir -p $(BUILD)/sdlmixer
	cd $(BUILD)/sdlmixer && $(ENV) $(SRCROOT)/SDL_mixer-1.2.12/configure \
		--build=$(TRIPLE) --prefix=$(INSTALL)/usr --with-freetype-prefix=$(INSTALL)/usr/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd $(BUILD)/sdlmixer && $(ENV) make -j$(THREADS) && make install
	rm -f $(INSTALL)/usr/lib/libSDL_mixer.a
	$(SDK)/usr/bin/ar crus $(INSTALL)/usr/lib/libSDL_mixer.a $(BUILD)/sdlmixer/build/*.o

freetype:
	rm -rf $(BUILD)/freetype
	mkdir -p $(BUILD)/freetype
	cd $(BUILD)/freetype && $(ENV) $(SRCROOT)/freetype-2.4.8/configure --build=$(TRIPLE) \
		--without-bzip2 --without-ats --without-old-mac-fonts --disable-mmap --enable-static --disable-shared --prefix=$(INSTALL)/usr
	cd $(BUILD)/freetype && $(ENV) make -j$(THREADS) && PATH=$(SDK)/usr/bin:$(PATH) make install
