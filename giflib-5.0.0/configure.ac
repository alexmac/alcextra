dnl Process this file with autoconf to produce a configure script.
AC_INIT(giflib, [5.0.0], [esr@thyrsus.com], giflib)
AC_CONFIG_SRCDIR([lib/dgif_lib.c])
AM_INIT_AUTOMAKE([gnu dist-bzip2 -Wall])

dnl Note: config.h is not used in the current build
dnl We leave this in place only to supptess an error message at autogen time
AM_CONFIG_HEADER(config.h)

dnl Checks for programs.
AC_PROG_LIBTOOL
AC_PROG_CC
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AM_PROG_CC_C_O

dnl Shared-library version
SHLIBVERSION=6:0:0

dnl Define warnings if we're compiling with gcc.
dnl Set it in CFLAGS so the end-user can disable it if they wish.
if test "x$GCC" = "xyes" ; then
  CFLAGS="$CFLAGS -Wall"
fi

dnl Checks for additional libtool flags (platform-dependant)

LT_LDFLAGS=""
case "$host" in
  *mingw*)
    LT_LDFLAGS="-no-undefined"
    ;;
esac

dnl Checks for libraries.

AC_CHECK_LIB(m, pow, [MATH_LIB="${MATH_LIB} -lm"
		      COMPILABLE_EXTRAS="${COMPILABLE_EXTRAS} gifclrmp${EXEEXT}"] )

AC_SUBST(COMPILABLE_EXTRAS)
AC_SUBST(MATH_LIB)
AC_SUBST(SHLIBVERSION)
AC_SUBST(LT_LDFLAGS)

AC_CHECK_HEADERS(limits.h, ,
                 AC_MSG_ERROR([giflib needs limits.h to compile]))
AC_CHECK_HEADERS(fcntl.h, ,
		 AC_MSG_ERROR([giflib needs fcntl.h to compile]))
AC_CHECK_HEADERS(stdint.h, ,
		 AC_MSG_ERROR([giflib needs stdint.h to compile]))
AC_CHECK_HEADERS(stdarg.h, ,
		 AC_MSG_ERROR([giflib needs stdarg.h to compile]))

AC_CONFIG_FILES([
util/Makefile
lib/Makefile
Makefile
doc/Makefile
pic/Makefile
])
AC_OUTPUT
