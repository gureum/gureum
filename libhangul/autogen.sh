#!/bin/sh


test -f ChangeLog || touch ChangeLog

libtoolize=`which glibtoolize`
if test -z "$libtoolize"; then
    libtoolize=libtoolize
fi

autopoint --force
$libtoolize --automake --copy --force
aclocal $ACLOCAL_AMFLAGS
autoheader
automake --add-missing --copy
autoconf
