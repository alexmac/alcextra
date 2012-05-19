AUTOMAKE_OPTIONS = foreign #include-deps
EXTRA_DIST = config.dos config.os2 Makefile.dos Makefile.os2 aados.c aadoskbd.c aadosmou.c aaos2.c  aaos2kbd.c aaos2mou.c  aaint.h aamktabl.h aaxint.h toc.c
lib_LTLIBRARIES=libaa.la
libaa_la_SOURCES= \
       aafont.c \
       aafonts.c \
       aavyhen.c \
       aamktabl.c \
       aamem.c \
       aaprintf.c \
       aahelp.c \
       aaslnkbd.c \
       aaslang.c \
       aafastre.c \
       aalinux.c \
       aalinuxkbd.c \
       aax.c \
       aaxkbd.c \
       aaxmouse.c \
       fontgl.c \
       font16.c \
       font14.c \
       fontx16.c \
       fontx13.c \
       fontx13b.c \
       fontcour.c \
       aarec.c \
       font9.c \
       font8.c \
       fontline.c \
       aacurses.c \
       aacurkbd.c \
       aacurmou.c \
       aalib.c \
       aaflush.c \
       aarender.c \
       aaout.c \
       aain.c \
       aaedit.c \
       aaregist.c \
       aakbdreg.c \
       aagpm.c  \
       aamoureg.c \
       aasave.c \
       aastdout.c \
       aastdin.c \
       aaparse.c \
       aaimgwidth.c \
       aaimgheight.c \
       aascrwidth.c \
       aascrheight.c \
       aammwidth.c \
       aammheight.c \
       aaimage.c \
       aatext.c \
       aacurrfnt.c \
       aaattrs.c \
       aaputpixel.c \
       aarecfunc.c 
libaa_la_LDFLAGS=@LDFLAGS@ -version-info 1:4:0
bin_PROGRAMS=aainfo aatest aafire aasavefont

aainfo_LDADD= libaa.la
aainfo_LDFLAGS= @LDFLAGS@
aatest_LDADD= libaa.la
aatest_LDFLAGS= @LDFLAGS@
aafire_LDADD= libaa.la
aafire_LDFLAGS= @LDFLAGS@
aasavefont_LDADD= libaa.la
aasavefont_LDFLAGS= @LDFLAGS@


include_HEADERS=aalib.h
