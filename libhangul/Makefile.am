SUBDIRS = hangul data tools po
DIST_SUBDIRS = hangul data tools po test

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libhangul.pc

EXTRA_DIST = \
    config.rpath \
    doc/Makefile \
    doc/Doxyfile.in \
    doc/mainpage.dox \
    test/Makefile.am \
    test/Makefile.in \
    test/hangul.c \
    test/hanja.c \
    test/test.c

log:
	unset LC_ALL; \
	export LANG=C ; \
	export LC_CTYPE=ko_KR.UTF-8; \
	svn log -v > ChangeLog

ACLOCAL_AMFLAGS = -I m4
