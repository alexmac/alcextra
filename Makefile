FLASCC=/path/to/FLASCC/sdk
BUILD="$(PWD)/build"
INSTALL="$(PWD)/install"
SRCROOT="$(PWD)"
THREADS=`sysctl -n hw.ncpu`
TRIPLE=avm2-unknown-freebsd8
PKG_CONFIG_PATH=$(FLASCC)/usr/lib/pkgconfig:$(INSTALL)/usr/lib/pkgconfig

ENV=PATH="$(FLASCC)/usr/bin":"$(INSTALL)/usr/bin":"$(PATH)" PKG_CONFIG_PATH="$(PKG_CONFIG_PATH)" CC=gcc CXX=g++ CFLAGS=-O4 CXXFLAGS=-O4

all:
	mkdir -p "$(BUILD)"
	mkdir -p "$(INSTALL)"

	@if [ -d "$(FLASCC)/usr/bin" ] ; then true ; \
		else echo "Couldn't locate FLASCC sdk directory, please invoke make with \"make FLASCC=/path/to/FLASCC/sdk ...\"" ; exit 1 ; \
	fi	
	
	make ncurses
	make readline

	make libogg
	#make libtiff
	make giflib
	make xz

	make libwebp
	make libvorbis
	make aalib

	make freetype
	make sdlttf
	make sdlmixer
	make sdlimage
	make physfs

	make gmp
	make eigen

	rm -f "$(INSTALL)"/usr/lib/*.la

.PHONY: physfs

clean:
	rm -rf "$(BUILD)"


protobuf:
	rm -rf "$(BUILD)/protobuf"
	mkdir -p "$(BUILD)/protobuf"
	cd "$(BUILD)/protobuf" && CC=gcc CFLAGS="-O4" CXXFLAGS="-O4" PATH="$(FLASCC)/usr/bin":"$(PATH)" "$(SRCROOT)/protobuf-2.4.1/configure" \
		--prefix="$(INSTALL)/usr" --disable-shared
	cd "$(BUILD)/protobuf" && CC=gcc CFLAGS="-O4" CXXFLAGS="-O4" PATH="$(FLASCC)/usr/bin":"$(PATH)" make -j6
	cd "$(BUILD)/protobuf" && CC=gcc CFLAGS="-O4" CXXFLAGS="-O4" PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

protobufexample:
	# compile the tutorial (https://developers.google.com/protocol-buffers/docs/cpptutorial)
	mkdir -p "$(BUILD)/protobufexample"
	"$(SRCROOT)/install/usr/bin/protoc" -I="$(SRCROOT)/protobuf-2.4.1/flash/" --cpp_out="$(BUILD)/protobufexample" "$(SRCROOT)/protobuf-2.4.1/flash/example.proto"
	"$(FLASCC)/usr/bin/g++" \
		-emit-swf -O4 \
		-o "$(BUILD)/protobufexample/example.swf" \
		-I"$(INSTALL)/usr/include" -I"$(BUILD)/protobufexample" \
		"$(BUILD)/protobufexample/example.pb.cc" "$(SRCROOT)/protobuf-2.4.1/flash/example.cpp" \
		-L"$(INSTALL)/usr/lib" -Wl,--start-group -lprotoc -lprotobuf -Wl,--end-group \

physfs:
	rm -rf "$(BUILD)/physfs"
	mkdir -p "$(BUILD)/physfs"
	cd "$(BUILD)/physfs" && $(ENV) cmake -G "Unix Makefiles" -DCMAKE_PREFIX_PATH="$(FLASCC)/" "$(SRCROOT)/physfs" \
		-DCMAKE_INSTALL_PREFIX="$(INSTALL)/usr" -DPHYSFS_BUILD_TEST=0 -DPHYSFS_HAVE_THREAD_SUPPORT=0 \
		-DPHYSFS_HAVE_CDROM_SUPPORT=0 -DPHYSFS_BUILD_STATIC=1 -DPHYSFS_BUILD_SHARED=0 -DPHYSFS_BUILD_PERL=0 \
		-DPHYSFS_BUILD_RUBY=0 -DOTHER_LDFLAGS=-lz -DPHYSFS_NO_64BIT_SUPPORT=1 -DCMAKE_INCLUDE_PATH="$(INSTALL)/usr/include" \
		-DCMAKE_LIBRARY_PATH="$(INSTALL)/usr/lib:$(FLASCC)/usr/lib"
	cd "$(BUILD)/physfs" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

aalib:
	rm -rf "$(BUILD)/aalib"
	mkdir -p "$(BUILD)/aalib"
	cd "$(BUILD)/aalib" && $(ENV) "$(SRCROOT)/aalib-1.4.0/configure" --host=$(TRIPLE) --prefix="$(INSTALL)/usr" \
		--enable-static --disable-shared --without-x --with-curses-driver=no
	cd "$(BUILD)/aalib" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

ncurses:
	rm -rf "$(BUILD)/ncurses"
	mkdir -p "$(BUILD)/ncurses"
	cd "$(BUILD)/ncurses" && $(ENV) "$(SRCROOT)/ncurses-5.9/configure" --host=$(TRIPLE) --prefix="$(INSTALL)/usr" \
		--enable-static --disable-shared --disable-pthread --without-shared --without-debug --without-tests \
		--without-progs --without-dlsym 
	cd "$(BUILD)/ncurses" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

readline:
	rm -rf "$(BUILD)/readline"
	mkdir -p "$(BUILD)/readline"
	cd "$(BUILD)/readline" && $(ENV) "$(SRCROOT)/readline-6.2/configure" \
		--build=$(TRIPLE) --prefix="$(INSTALL)/usr" --with-curses --enable-static --disable-shared --without-shared
	cd "$(BUILD)/readline" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install-static

giflib:
	rm -rf "$(BUILD)/giflib"
	mkdir -p "$(BUILD)/giflib"
	cd "$(BUILD)/giflib" && $(ENV) "$(SRCROOT)/giflib-5.0.0/configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared
	cd "$(BUILD)/giflib" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

libogg:
	rm -rf "$(BUILD)/libogg"
	mkdir -p "$(BUILD)/libogg"
	cd "$(BUILD)/libogg" && $(ENV) "$(SRCROOT)/libogg-1.3.0/configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared
	cd "$(BUILD)/libogg" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

libvorbis:
	rm -rf "$(BUILD)/libvorbis"
	mkdir -p "$(BUILD)/libvorbis"
	cd "$(BUILD)/libvorbis" && $(ENV) "$(SRCROOT)/libvorbis-1.3.2/configure" \
		--build=$(TRIPLE) --host=$(TRIPLE) --prefix="$(INSTALL)/usr" --disable-oggtest --disable-examples \
		--disable-docs --enable-static --disable-shared
	cd "$(BUILD)/libvorbis" && $(ENV) make -j$(THREADS) && $(ENV) make install

libtiff:
	rm -rf "$(BUILD)/libtiff"
	cp -r $(SRCROOT)/tiff-4.0.1 $(BUILD)/libtiff
	cd "$(BUILD)/libtiff" && $(ENV) "./configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared
	cd "$(BUILD)/libtiff" && $(ENV) make -j$(THREADS) && $(ENV) make -j$(THREADS) install

libwebp:
	rm -rf "$(BUILD)/libwebp"
	mkdir -p "$(BUILD)/libwebp"
	cd "$(BUILD)/libwebp" && $(ENV) LIBPNG_CFLAGS="-I$(FLASCC)/usr/include/libpng15/" LIBPNG_LIBS="-lpng -lz" "$(SRCROOT)/libwebp-0.1.3/configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared
	cd "$(BUILD)/libwebp" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

xz:
	rm -rf "$(BUILD)/xz"
	mkdir -p "$(BUILD)/xz"
	cd "$(BUILD)/xz" && $(ENV) "$(SRCROOT)/xz-5.0.3/configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared \
		--enable-encoders=lzma1,lzma2,delta --enable-decoders=lzma1,lzma2,delta --disable-assembler \
		--disable-threads
	cd "$(BUILD)/xz" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

libiconv:
	rm -rf "$(BUILD)/libiconv"
	mkdir -p "$(BUILD)/libiconv"
	cd "$(BUILD)/libiconv" && $(ENV) "$(SRCROOT)/libiconv-1.14/configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared
	cd "$(BUILD)/libiconv" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

libgmp:
	rm -rf "$(BUILD)/libgmp"
	mkdir -p "$(BUILD)/libgmp"
	cd "$(BUILD)/libgmp" && $(ENV) "$(SRCROOT)/gmp-5.0.5/configure" \
		--host=$(TRIPLE) --prefix="$(INSTALL)/usr" --enable-static --disable-shared
	cd "$(BUILD)/libgmp" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

libsdl:
	# pulled from elsewhere, so won't work without making this conform to the paths used in the rest of this repo
	# buyer beware!
	#$(ENV) $(SRCROOT)/SDL-1.2.14/configure \
	#	--host=$(TRIPLE) --prefix=$(SDK)/usr --disable-pthreads --disable-alsa --disable-video-x11 \
	#	--disable-cdrom --disable-loadso --disable-assembly --disable-esd --disable-arts --disable-nas \
	#	--disable-nasm --disable-altivec --disable-dga --disable-screensaver --disable-sdl-dlopen \
	#	--disable-directx --enable-joystick --enable-video-vgl --enable-static --disable-shared
	#perl -p -i -e 's~$(SRCROOT)~FLASCC_SRC_DIR~g' `grep -ril $(SRCROOT) cached_build/`
	#rm $(SRCROOT)/cached_build/libsdl/config.status

	#perl -p -i -e 's~FLASCC_SRC_DIR~$(SRCROOT)~g' `grep -ril FLASCC_SRC_DIR $(BUILD)/libsdl/`

	#cd $(BUILD)/libsdl && PATH='$(SDK)/usr/bin:$(PATH)' make -j$(THREADS)
	#cd $(BUILD)/libsdl && PATH='$(SDK)/usr/bin:$(PATH)' make install
	#make libsdl-install
	#rm $(SDK)/usr/include/SDL/SDL_opengl.h


sdlttf:
	rm -rf "$(BUILD)/sdlttf"
	mkdir -p "$(BUILD)/sdlttf"
	cd "$(BUILD)/sdlttf" && $(ENV) "$(SRCROOT)/SDL_ttf-2.0.10/configure" \
		--build=$(TRIPLE) --prefix="$(INSTALL)/usr" --with-freetype-prefix="$(INSTALL)/usr"/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd "$(BUILD)/sdlttf" && $(ENV) make -j$(THREADS) && make install
	rm -f "$(INSTALL)/usr/lib/libSDL_ttf.a"
	"$(FLASCC)/usr/bin/ar" crus "$(INSTALL)/usr/lib/libSDL_ttf.a" "$(BUILD)/sdlttf/SDL_ttf.o"

sdlimage:
	rm -rf "$(BUILD)/sdlimage"
	mkdir -p "$(BUILD)/sdlimage"
	cd "$(BUILD)/sdlimage" && $(ENV) LIBPNG_CFLAGS="-I$(FLASCC)/usr/include/libpng15/" LIBPNG_LIBS=-lpng $(SRCROOT)/SDL_image-1.2.12/configure \
		--build=$(TRIPLE) --prefix="$(INSTALL)/usr" --with-freetype-prefix="$(INSTALL)/usr"/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd "$(BUILD)/sdlimage" && $(ENV) make -j$(THREADS) && make install
	rm -f "$(INSTALL)/usr/lib/libSDL_image.a"
	"$(FLASCC)/usr/bin/ar" crus "$(INSTALL)/usr/lib/libSDL_image.a" "$(BUILD)"/sdlimage/*.o

sdlmixer:
	rm -rf "$(BUILD)/sdlmixer"
	mkdir -p "$(BUILD)/sdlmixer"
	cd "$(BUILD)/sdlmixer" && $(ENV) "$(SRCROOT)/SDL_mixer-1.2.12/configure" \
		--build=$(TRIPLE) --prefix="$(INSTALL)/usr" --with-freetype-prefix="$(INSTALL)/usr"/ \
		--disable-sdltest --disable-dependency-tracking --enable-static --disable-shared --without-x
	cd "$(BUILD)/sdlmixer" && $(ENV) make -j$(THREADS) && make install
	rm -f "$(INSTALL)/usr/lib/libSDL_mixer.a"
	"$(FLASCC)/usr/bin/ar" crus "$(INSTALL)/usr/lib/libSDL_mixer.a" "$(BUILD)"/sdlmixer/build/*.o

freetype:
	rm -rf "$(BUILD)/freetype"
	mkdir -p "$(BUILD)/freetype"
	cd "$(BUILD)/freetype" && $(ENV) "$(SRCROOT)/freetype-2.4.8/configure" --build=$(TRIPLE) \
		--without-bzip2 --without-ats --without-old-mac-fonts --disable-mmap --enable-static --disable-shared --prefix="$(INSTALL)/usr"
	cd "$(BUILD)/freetype" && $(ENV) make -j$(THREADS) && PATH="$(FLASCC)/usr/bin":"$(PATH)" make install

eigen:
	rm -rf "$(BUILD)/eigen"
	mkdir -p "$(BUILD)/eigen"
	cd "$(BUILD)/eigen" && $(ENV) cmake "$(SRCROOT)/eigen-3.1.2" -DCMAKE_INSTALL_PREFIX="$(INSTALL)/usr"
	cd "$(BUILD)/eigen" && $(ENV) make -j$(THREADS) install
