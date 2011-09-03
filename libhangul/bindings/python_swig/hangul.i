%module hangul
%{
#include "hangul.h"
#include <iconv.h>

/* FIXME - to avoid undifined symbol error */
ucschar hangul_choseong_to_jamo(ucschar ch) { return 0; }
ucschar hangul_jungseong_to_jamo(ucschar ch) { return 0; }
ucschar hangul_jongseong_to_jamo(ucschar ch) { return 0; }
int hanja_table_txt_to_bin(const char* txtfilename, const char* binfilename)
{ return 0; }

#ifdef WORDS_BIGENDIAN
#define UCS4 "UCS-4BE"
#else
#define UCS4 "UCS-4LE"
#endif

void ucs4_to_utf8(char *buf, const ucschar *ucs4, size_t bufsize)
{
    size_t n;
    char*  inbuf;
    size_t inbytesleft;
    char*  outbuf;
    size_t outbytesleft;
    size_t ret;
    iconv_t cd;

    for (n = 0; ucs4[n] != 0; n++)
        continue;

    if (n == 0) {
        buf[0] = '\0';
        return;
    }

    cd = iconv_open("UTF-8", UCS4);
    if (cd == (iconv_t)(-1))
        return;

    inbuf = (char*)ucs4;
    inbytesleft = n * 4;
    outbuf = buf;
    outbytesleft = bufsize;
    ret = iconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);

    iconv_close(cd);

    if (outbytesleft > 0)
        *outbuf = '\0';
    else
        buf[bufsize - 1] = '\0';
}


%}

%typemap(out) const ucschar* {
    char commit[32] = { '\0', };
    ucs4_to_utf8(commit, $1, sizeof(commit));
    $result = PyString_FromString(commit);
}

%typemap(out) ucschar {
    $result = Py_BuildValue("I", $1);
}

%typemap(in) ucschar {
    if(!PyInt_Check($input)) {
        PyErr_SetString(PyExc_ValueError, "Expected a int");
        return NULL;
    }
    $1 = (ucschar)PyInt_AS_LONG($input);
}



%include "hangul.h"
