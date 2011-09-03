#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iconv.h>

#include "../hangul/hangul.h"

#ifdef WORDS_BIGENDIAN
#define UCS4 "UCS-4BE"
#else
#define UCS4 "UCS-4LE"
#endif

#ifndef ICONV_CONST
#define ICONV_CONST
#endif

void ucs4_to_utf8(char *buf, const ucschar *ucs4, size_t bufsize)
{
    size_t n;
    ICONV_CONST char*  inbuf;
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

int
main(int argc, char *argv[])
{
    int ascii;
    const char* keyboard = "2";
    char commit[32] = { '\0', };
    HangulInputContext *hic;

    if (argc > 1) {
	keyboard = argv[1];
    }

    hic = hangul_ic_new(keyboard);
    if (hic == NULL) {
	printf("hic is null\n");
	return -1;
    }

    for (ascii = getchar(); ascii != EOF; ascii = getchar()) {
	int ret = hangul_ic_process(hic, ascii);
	ucs4_to_utf8(commit, hangul_ic_get_commit_string(hic), sizeof(commit));
	if (strlen(commit) > 0) {
	    printf("%s", commit);
	}
	if (!ret) {
	    printf("%c", ascii);
	}
    } 

    if (!hangul_ic_is_empty(hic)) {
	ucs4_to_utf8(commit, hangul_ic_flush(hic), sizeof(commit));
	if (strlen(commit) > 0) {
	    printf("%s", commit);
	}
    }

    hangul_ic_delete(hic);

    return 0;
}
