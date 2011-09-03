#ifndef libhangul_hangulinternals_h
#define libhangul_hangulinternals_h

#define N_ELEMENTS(array) (sizeof (array) / sizeof ((array)[0]))

ucschar hangul_jongseong_get_diff(ucschar prevjong, ucschar jong);

#endif /* libhangul_hangulinternals_h */
