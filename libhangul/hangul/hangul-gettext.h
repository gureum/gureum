#ifndef libhangul_hangul_gettext_h
#define libhangul_hangul_gettext_h

#ifdef ENABLE_NLS

#include <libintl.h>

#define _(x)	    dgettext(GETTEXT_PACKAGE, x)
#define N_(x)	    x

#else /* ENABLE_NLS */

#define _(x)	    (x)
#define N_(x)	    x

#endif /* ENABLE_NLS */

#endif // libhangul_hangul_gettext_h
