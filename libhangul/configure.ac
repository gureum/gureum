#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.57)
AC_INIT(libhangul, 0.0.12, http://kldp.net/projects/hangul/)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([hangul/hangul.h])
AC_CONFIG_HEADER([config.h])

# library version
LIBHANGUL_CURRENT=1
LIBHANGUL_REVISION=4
LIBHANGUL_AGE=1

AC_SUBST(LIBHANGUL_CURRENT)
AC_SUBST(LIBHANGUL_REVISION)
AC_SUBST(LIBHANGUL_AGE)

# Checks for programs.
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_LIBTOOL
AC_PROG_INSTALL

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h string.h limits.h])
AC_CHECK_HEADERS([langinfo.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_BIGENDIAN
AC_C_CONST
AC_C_INLINE
#AC_TYPE_UINT32_T

# Checks for library functions.
AC_FUNC_MEMCMP
AC_FUNC_MMAP
AC_FUNC_REALLOC
AC_CHECK_FUNCS([munmap])
AC_CHECK_FUNCS([strcasecmp])
AC_CHECK_FUNCS([nl_langinfo])

# Checks for gettext stuff
GETTEXT_PACKAGE="$PACKAGE"
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", gettext package name)
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION(0.11)
AM_ICONV

# Checks for unit test framework
PKG_PROG_PKG_CONFIG
if test -n "$PKG_CONFIG"; then
    PKG_CHECK_EXISTS(check, [ PKG_CHECK_MODULES([CHECK], [check]) ])
fi

AC_CONFIG_FILES([
Makefile
data/Makefile
data/hanja/Makefile
doc/Doxyfile
hangul/Makefile
libhangul.pc
po/Makefile.in
test/Makefile
tools/Makefile
])

AC_OUTPUT
