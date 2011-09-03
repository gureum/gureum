/* libhangul
 * Copyright (C) 2004 - 2009 Choe Hwanjin
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdlib.h>

#include "hangul.h"

/**
 * @defgroup hangulctype 한글 글자 조작
 * 
 * @section hangulctype 한글 글자 조작
 * libhangul은 한글 각 글자를 구분하고 조작하는데 사용할 수 있는 몇가지 함수를
 * 제공한다.  libhangul의 글자 구분 함수의 인터페이스에서 글자의 기본 단위는
 * UCS4 코드값이다.
 */

/**
 * @file hangulctype.c
 */

/**
 * @ingroup hangulctype
 * @typedef ucschar
 * @brief UCS4 코드 단위의 글자 코드 값
 *
 * UCS4 코드 값을 저장한다. libhangul에서 사용하는 문자열의 기본단위이다.
 * preedit 문자열과 commit 문자열 모두 ucschar 포인터 형으로 전달된다.
 * 이 스트링은  C 스트링과 유사하게 0으로 끝난다.
 * 유니코드 값이 한글의 어떤 범주에 속하는지 확인하는 함수도 모두 ucschar 형을
 * 사용한다.
 */

static const ucschar syllable_base  = 0xac00;
static const ucschar choseong_base  = 0x1100;
static const ucschar jungseong_base = 0x1161;
static const ucschar jongseong_base = 0x11a7;
static const int njungseong = 21;
static const int njongseong = 28;

/**
 * @ingroup hangulctype
 * @brief 초성인지 확인하는 함수
 * @param c UCS4 코드 값
 * @return @a c 가 초성에 해당하면 true를 리턴함, 아니면 false
 * 
 * @a c 로 주어진 UCS4 코드가 초성인지 확인한다.
 * Unicode 5.2 지원
 */
bool
hangul_is_choseong(ucschar c)
{
    return (c >= 0x1100 && c <= 0x115f) ||
	   (c >= 0xa960 && c <= 0xa97c);
;
}

/**
 * @ingroup hangulctype
 * @brief 중성인지 확인하는 함수
 * @param c UCS4 코드 값
 * @return @a c 가 중성에 해당하면 true를 리턴함, 아니면 false
 * 
 * @a c 로 주어진 UCS4 코드가 중성인지 확인한다.
 * Unicode 5.2 지원
 */
bool
hangul_is_jungseong(ucschar c)
{
    return (c >= 0x1160 && c <= 0x11a7) ||
	   (c >= 0xd7b0 && c <= 0xd7c6);
}

/**
 * @ingroup hangulctype
 * @brief 종성인지 확인하는 함수
 * @param c UCS4 코드 값
 * @return @a c 가 종성에 해당하면 true를 리턴함, 아니면 false
 * 
 * @a c 로 주어진 UCS4 코드가 종성인지 확인한다.
 * Unicode 5.2 지원
 */
bool
hangul_is_jongseong(ucschar c)
{
    return (c >= 0x11a8 && c <= 0x11ff) ||
	   (c >= 0xd7cb && c <= 0xd7fb);
}

bool
hangul_is_combining_mark(ucschar c)
{
    return  c == 0x302e || c == 0x302f  ||
	   (c >= 0x0300 && c <= 0x036F) ||
	   (c >= 0x1dc0 && c <= 0x1dff) ||
	   (c >= 0xfe20 && c <= 0xfe2f);
}

/**
 * @ingroup hangulctype
 * @brief 초성이고 조합 가능한지 확인
 */
bool
hangul_is_choseong_conjoinable(ucschar c)
{
    return c >= 0x1100 && c <= 0x1112;
}

/**
 * @ingroup hangulctype
 * @brief 중성이고 조합 가능한지 확인
 */
bool
hangul_is_jungseong_conjoinable(ucschar c)
{
    return c >= 0x1161 && c <= 0x1175;
}

/**
 * @ingroup hangulctype
 * @brief 종성이고 조합 가능한지 확인
 */
bool
hangul_is_jongseong_conjoinable(ucschar c)
{
    return c >= 0x11a7 && c <= 0x11c2;
}

/**
 * @ingroup hangulctype
 * @brief 한글 음절 인지 확
 * @param c UCS4 코드 값
 * @return @a c가 한글 음절 코드이면 true, 그 외에는 false
 *
 * 이 함수는 @a c로 주어진 UCS4 코드가 현대 한글 음절에 해당하는지
 * 확인한다.
 */
bool
hangul_is_syllable(ucschar c)
{
    return c >= 0xac00 && c <= 0xd7a3;
}

/**
 * @ingroup hangulctype
 * @brief 자모 인지 확인
 * @param c UCS4 코드 값
 * @return @a c 가 자모 코드이면 true를 리턴, 그외에는 false
 *
 * @a c 로 주어진 UCS4 코드가 자모 코드인지 확인한다.
 * Unicode 5.2 지원
 */
bool
hangul_is_jamo(ucschar c)
{
    return hangul_is_choseong(c) ||
	   hangul_is_jungseong(c) ||
	   hangul_is_jongseong(c);
}

/** @deprecated 이 함수 대신 hangul_is_jamo()함수를 사용한다. */
bool
hangul_is_jaso(ucschar c)
{
    return hangul_is_jamo(c);
}

/**
 * @ingroup hangulctype
 * @brief 호환 자모인지 확인
 * @param c UCS4 코드 값
 * @return @a c가 호환자모이면 true, 그 외에는 false
 *
 * 이 함수는 @a c로 주어진 UCS4 코드가 호환 자모인지 확인한다.
 */
bool
hangul_is_cjamo(ucschar c)
{
    return c >= 0x3131 && c <= 0x318e;
}

/**
 * @ingroup hangulctype
 * @brief 자모 코드를 대응하는 호환 자모로 변환
 * @param c 변환할 UCS4 코드 값
 * @return @a c 에 대응되는 호환 자모 값, or c
 *
 * 이 함수는 @a c 로 주어진 자모 코드와 같은 형태를 가진 호환 자모 값을
 * 리턴한다.  자모와 같은 형태를 가진 호환 자모가 없는 경우에는 @a c 의 
 * 값을 그대로 리턴한다.
 */
ucschar
hangul_jamo_to_cjamo(ucschar c)
{
    static unsigned short jamo_table[] = {
	0x3131,     /* 0x1100 */
	0x3132,     /* 0x1101 */
	0x3134,     /* 0x1102 */
	0x3137,     /* 0x1103 */
	0x3138,     /* 0x1104 */
	0x3139,     /* 0x1105 */
	0x3141,     /* 0x1106 */
	0x3142,     /* 0x1107 */
	0x3143,     /* 0x1108 */
	0x3145,     /* 0x1109 */
	0x3146,     /* 0x110a */
	0x3147,     /* 0x110b */
	0x3148,     /* 0x110c */
	0x3149,     /* 0x110d */
	0x314a,     /* 0x110e */
	0x314b,     /* 0x110f */
	0x314c,     /* 0x1110 */
	0x314d,     /* 0x1111 */
	0x314e,     /* 0x1112 */
	0x0000,     /* 0x1113 */
	0x3165,     /* 0x1114 */
	0x3166,     /* 0x1115 */
	0x0000,     /* 0x1116 */
	0x0000,     /* 0x1117 */
	0x0000,     /* 0x1118 */
	0x0000,     /* 0x1119 */
	0x3140,     /* 0x111a */
	0x0000,     /* 0x111b */
	0x316e,     /* 0x111c */
	0x3171,     /* 0x111d */
	0x3172,     /* 0x111e */
	0x0000,     /* 0x111f */
	0x3173,     /* 0x1120 */
	0x3144,     /* 0x1121 */
	0x3174,     /* 0x1122 */
	0x3175,     /* 0x1123 */
	0x0000,     /* 0x1124 */
	0x0000,     /* 0x1125 */
	0x0000,     /* 0x1126 */
	0x3176,     /* 0x1127 */
	0x0000,     /* 0x1128 */
	0x3177,     /* 0x1129 */
	0x0000,     /* 0x112a */
	0x3178,     /* 0x112b */
	0x3179,     /* 0x112c */
	0x317a,     /* 0x112d */
	0x317b,     /* 0x112e */
	0x317c,     /* 0x112f */
	0x0000,     /* 0x1130 */
	0x0000,     /* 0x1131 */
	0x317d,     /* 0x1132 */
	0x0000,     /* 0x1133 */
	0x0000,     /* 0x1134 */
	0x0000,     /* 0x1135 */
	0x317e,     /* 0x1136 */
	0x0000,     /* 0x1137 */
	0x0000,     /* 0x1138 */
	0x0000,     /* 0x1139 */
	0x0000,     /* 0x113a */
	0x0000,     /* 0x113b */
	0x0000,     /* 0x113c */
	0x0000,     /* 0x113d */
	0x0000,     /* 0x113e */
	0x0000,     /* 0x113f */
	0x317f,     /* 0x1140 */
	0x0000,     /* 0x1141 */
	0x0000,     /* 0x1142 */
	0x0000,     /* 0x1143 */
	0x0000,     /* 0x1144 */
	0x0000,     /* 0x1145 */
	0x0000,     /* 0x1146 */
	0x3180,     /* 0x1147 */
	0x0000,     /* 0x1148 */
	0x0000,     /* 0x1149 */
	0x0000,     /* 0x114a */
	0x0000,     /* 0x114b */
	0x3181,     /* 0x114c */
	0x0000,     /* 0x114d */
	0x0000,     /* 0x114e */
	0x0000,     /* 0x114f */
	0x0000,     /* 0x1150 */
	0x0000,     /* 0x1151 */
	0x0000,     /* 0x1152 */
	0x0000,     /* 0x1153 */
	0x0000,     /* 0x1154 */
	0x0000,     /* 0x1155 */
	0x0000,     /* 0x1156 */
	0x3184,     /* 0x1157 */
	0x3185,     /* 0x1158 */
	0x3186,     /* 0x1159 */
	0x0000,     /* 0x115a */
	0x0000,     /* 0x115b */
	0x0000,     /* 0x115c */
	0x0000,     /* 0x115d */
	0x0000,     /* 0x115e */
	0x0000,     /* 0x115f */
	0x3164,     /* 0x1160 */
	0x314f,     /* 0x1161 */
	0x3150,     /* 0x1162 */
	0x3151,     /* 0x1163 */
	0x3152,     /* 0x1164 */
	0x3153,     /* 0x1165 */
	0x3154,     /* 0x1166 */
	0x3155,     /* 0x1167 */
	0x3156,     /* 0x1168 */
	0x3157,     /* 0x1169 */
	0x3158,     /* 0x116a */
	0x3159,     /* 0x116b */
	0x315a,     /* 0x116c */
	0x315b,     /* 0x116d */
	0x315c,     /* 0x116e */
	0x315d,     /* 0x116f */
	0x315e,     /* 0x1170 */
	0x315f,     /* 0x1171 */
	0x3160,     /* 0x1172 */
	0x3161,     /* 0x1173 */
	0x3162,     /* 0x1174 */
	0x3163,     /* 0x1175 */
	0x0000,     /* 0x1176 */
	0x0000,     /* 0x1177 */
	0x0000,     /* 0x1178 */
	0x0000,     /* 0x1179 */
	0x0000,     /* 0x117a */
	0x0000,     /* 0x117b */
	0x0000,     /* 0x117c */
	0x0000,     /* 0x117d */
	0x0000,     /* 0x117e */
	0x0000,     /* 0x117f */
	0x0000,     /* 0x1180 */
	0x0000,     /* 0x1181 */
	0x0000,     /* 0x1182 */
	0x0000,     /* 0x1183 */
	0x3187,     /* 0x1184 */
	0x3188,     /* 0x1185 */
	0x0000,     /* 0x1186 */
	0x0000,     /* 0x1187 */
	0x3189,     /* 0x1188 */
	0x0000,     /* 0x1189 */
	0x0000,     /* 0x118a */
	0x0000,     /* 0x118b */
	0x0000,     /* 0x118c */
	0x0000,     /* 0x118d */
	0x0000,     /* 0x118e */
	0x0000,     /* 0x118f */
	0x0000,     /* 0x1190 */
	0x318a,     /* 0x1191 */
	0x318b,     /* 0x1192 */
	0x0000,     /* 0x1193 */
	0x318c,     /* 0x1194 */
	0x0000,     /* 0x1195 */
	0x0000,     /* 0x1196 */
	0x0000,     /* 0x1197 */
	0x0000,     /* 0x1198 */
	0x0000,     /* 0x1199 */
	0x0000,     /* 0x119a */
	0x0000,     /* 0x119b */
	0x0000,     /* 0x119c */
	0x0000,     /* 0x119d */
	0x318d,     /* 0x119e */
	0x0000,     /* 0x119f */
	0x0000,     /* 0x11a0 */
	0x318e,     /* 0x11a1 */
	0x0000,     /* 0x11a2 */
	0x0000,     /* 0x11a3 */
	0x0000,     /* 0x11a4 */
	0x0000,     /* 0x11a5 */
	0x0000,     /* 0x11a6 */
	0x0000,     /* 0x11a7 */
	0x3131,	    /* 0x11a8 */
	0x3132,	    /* 0x11a9 */
	0x3133,	    /* 0x11aa */
	0x3134,	    /* 0x11ab */
	0x3135,	    /* 0x11ac */
	0x3136,	    /* 0x11ad */
	0x3137,	    /* 0x11ae */
	0x3139,	    /* 0x11af */
	0x313a,	    /* 0x11b0 */
	0x313b,	    /* 0x11b1 */
	0x313c,	    /* 0x11b2 */
	0x313d,	    /* 0x11b3 */
	0x313e,	    /* 0x11b4 */
	0x313f,	    /* 0x11b5 */
	0x3140,	    /* 0x11b6 */
	0x3141,	    /* 0x11b7 */
	0x3142,	    /* 0x11b8 */
	0x3144,	    /* 0x11b9 */
	0x3145,	    /* 0x11ba */
	0x3146,	    /* 0x11bb */
	0x3147,	    /* 0x11bc */
	0x3148,	    /* 0x11bd */
	0x314a,	    /* 0x11be */
	0x314b,	    /* 0x11bf */
	0x314c,	    /* 0x11c0 */
	0x314d,	    /* 0x11c1 */
	0x314e,	    /* 0x11c2 */
	0x0000,     /* 0x11c3 */
	0x0000,     /* 0x11c4 */
	0x0000,     /* 0x11c5 */
	0x0000,     /* 0x11c6 */
	0x3167,     /* 0x11c7 */
	0x3168,     /* 0x11c8 */
	0x0000,     /* 0x11c9 */
	0x0000,     /* 0x11ca */
	0x0000,     /* 0x11cb */
	0x3169,     /* 0x11cc */
	0x0000,     /* 0x11cd */
	0x316a,     /* 0x11ce */
	0x0000,     /* 0x11cf */
	0x0000,     /* 0x11d0 */
	0x0000,     /* 0x11d1 */
	0x0000,     /* 0x11d2 */
	0x316b,     /* 0x11d3 */
	0x0000,     /* 0x11d4 */
	0x0000,     /* 0x11d5 */
	0x0000,     /* 0x11d6 */
	0x316c,     /* 0x11d7 */
	0x0000,     /* 0x11d8 */
	0x316d,     /* 0x11d9 */
	0x0000,     /* 0x11da */
	0x0000,     /* 0x11db */
	0x0000,     /* 0x11dc */
	0x316f,     /* 0x11dd */
	0x0000,     /* 0x11de */
	0x3170,     /* 0x11df */
	0x0000,     /* 0x11e0 */
	0x0000,     /* 0x11e1 */
	0x0000,     /* 0x11e2 */
	0x0000,     /* 0x11e3 */
	0x0000,     /* 0x11e4 */
	0x0000,     /* 0x11e5 */
	0x0000,     /* 0x11e6 */
	0x0000,     /* 0x11e7 */
	0x0000,     /* 0x11e8 */
	0x0000,     /* 0x11e9 */
	0x0000,     /* 0x11ea */
	0x0000,     /* 0x11eb */
	0x0000,     /* 0x11ec */
	0x0000,     /* 0x11ed */
	0x0000,     /* 0x11ee */
	0x0000,     /* 0x11ef */
	0x0000,     /* 0x11f0 */
	0x3182,     /* 0x11f1 */
	0x3183,     /* 0x11f2 */
	0x0000,     /* 0x11f3 */
	0x0000,     /* 0x11f4 */
	0x0000,     /* 0x11f5 */
	0x0000,     /* 0x11f6 */
	0x0000,     /* 0x11f7 */
	0x0000,     /* 0x11f8 */
	0x0000,     /* 0x11f9 */
	0x0000,     /* 0x11fa */
	0x0000,     /* 0x11fb */
	0x0000,     /* 0x11fc */
	0x0000,     /* 0x11fd */
	0x0000,     /* 0x11fe */
	0x0000,     /* 0x11ff */
    };

    static unsigned short jamo_ext_A_table[] = {
	0x0000,     /* 0xa960 */
	0x0000,     /* 0xa961 */
	0x0000,     /* 0xa962 */
	0x0000,     /* 0xa963 */
	0x313a,     /* 0xa964 */
	0x0000,     /* 0xa965 */
	0x316a,     /* 0xa966 */
	0x0000,     /* 0xa967 */
	0x313b,     /* 0xa968 */
	0x313c,     /* 0xa969 */
	0x0000,     /* 0xa96a */
	0x0000,     /* 0xa96b */
	0x313d,     /* 0xa96c */
	0x0000,     /* 0xa96d */
	0x0000,     /* 0xa96e */
	0x0000,     /* 0xa96f */
	0x0000,     /* 0xa970 */
	0x316f,     /* 0xa971 */
	0x0000,     /* 0xa972 */
	0x0000,     /* 0xa973 */
	0x0000,     /* 0xa974 */
	0x0000,     /* 0xa975 */
	0x0000,     /* 0xa976 */
	0x0000,     /* 0xa977 */
	0x0000,     /* 0xa978 */
	0x0000,     /* 0xa979 */
	0x0000,     /* 0xa97a */
	0x0000,     /* 0xa97b */
	0x0000,     /* 0xa97c */
    };

    static unsigned short jamo_ext_B_table[] = {
	0x0000,     /* 0xd7b0 */
	0x0000,     /* 0xd7b1 */
	0x0000,     /* 0xd7b2 */
	0x0000,     /* 0xd7b3 */
	0x0000,     /* 0xd7b4 */
	0x0000,     /* 0xd7b5 */
	0x0000,     /* 0xd7b6 */
	0x0000,     /* 0xd7b7 */
	0x0000,     /* 0xd7b8 */
	0x0000,     /* 0xd7b9 */
	0x0000,     /* 0xd7ba */
	0x0000,     /* 0xd7bb */
	0x0000,     /* 0xd7bc */
	0x0000,     /* 0xd7bd */
	0x0000,     /* 0xd7be */
	0x0000,     /* 0xd7bf */
	0x0000,     /* 0xd7c0 */
	0x0000,     /* 0xd7c1 */
	0x0000,     /* 0xd7c2 */
	0x0000,     /* 0xd7c3 */
	0x0000,     /* 0xd7c4 */
	0x0000,     /* 0xd7c5 */
	0x0000,     /* 0xd7c6 */
	0x0000,     /* 0xd7cb */
	0x0000,     /* 0xd7cc */
	0x3138,     /* 0xd7cd */
	0x0000,     /* 0xd7ce */
	0x0000,     /* 0xd7cf */
	0x0000,     /* 0xd7d0 */
	0x0000,     /* 0xd7d1 */
	0x0000,     /* 0xd7d2 */
	0x0000,     /* 0xd7d3 */
	0x0000,     /* 0xd7d4 */
	0x0000,     /* 0xd7d5 */
	0x0000,     /* 0xd7d6 */
	0x0000,     /* 0xd7d7 */
	0x0000,     /* 0xd7d8 */
	0x0000,     /* 0xd7d9 */
	0x0000,     /* 0xd7da */
	0x0000,     /* 0xd7db */
	0x0000,     /* 0xd7dc */
	0x0000,     /* 0xd7dd */
	0x0000,     /* 0xd7de */
	0x0000,     /* 0xd7df */
	0x0000,     /* 0xd7e0 */
	0x0000,     /* 0xd7e1 */
	0x0000,     /* 0xd7e2 */
	0x3173,     /* 0xd7e3 */
	0x0000,     /* 0xd7e4 */
	0x0000,     /* 0xd7e5 */
	0x3143,     /* 0xd7e6 */
	0x3175,     /* 0xd7e7 */
	0x3176,     /* 0xd7e8 */
	0x0000,     /* 0xd7e9 */
	0x0000,     /* 0xd7ea */
	0x0000,     /* 0xd7eb */
	0x0000,     /* 0xd7ec */
	0x0000,     /* 0xd7ed */
	0x0000,     /* 0xd7ee */
	0x317e,     /* 0xd7ef */
	0x0000,     /* 0xd7f0 */
	0x0000,     /* 0xd7f1 */
	0x0000,     /* 0xd7f2 */
	0x0000,     /* 0xd7f3 */
	0x0000,     /* 0xd7f4 */
	0x0000,     /* 0xd7f5 */
	0x0000,     /* 0xd7f6 */
	0x0000,     /* 0xd7f7 */
	0x0000,     /* 0xd7f8 */
	0x3149,     /* 0xd7f9 */
	0x0000,     /* 0xd7fa */
	0x0000,     /* 0xd7fb */
    };

    ucschar ret = 0;

    if (c >= 0x1100 && c <= 0x11ff) {
	ret = jamo_table[c - 0x1100];
    } else if (c >= 0xa960 && c <= 0xa97c) {
	ret = jamo_ext_A_table[c - 0xa960];
    } else if (c >= 0xd7b0 && c <= 0xd7fb) {
	ret = jamo_ext_B_table[c - 0xd7b0];
    }

    if (ret == 0)
	ret = c;

    return ret;
}

/** @deprecated 이 함수 대신 hangul_jamo_to_cjamo()함수를 사용한다. */
ucschar
hangul_jaso_to_jamo(ucschar c)
{
    return hangul_jamo_to_cjamo(c);
}

ucschar
hangul_choseong_to_jongseong(ucschar c)
{
    static const ucschar table[] = {
	0x11a8,  /* cho kiyeok               -> jong kiyeok               */
	0x11a9,  /* cho ssangkiyeok          -> jong ssangkiyeok          */
	0x11ab,  /* cho nieun                -> jong nieun                */
	0x11ae,  /* cho tikeut               -> jong tikeut               */
	0xd7cd,  /* cho ssangtikeut          -> jong ssangtikeut          */
	0x11af,  /* cho rieul                -> jong rieul                */
	0x11b7,  /* cho mieum                -> jong mieum                */
	0x11b8,  /* cho pieup                -> jong pieup                */
	0xd7e6,  /* cho ssangpieup           -> jong ssangpieup           */
	0x11ba,  /* cho sios                 -> jong sios                 */
	0x11bb,  /* cho ssangsios            -> jong ssangsios            */
	0x11bc,  /* cho ieung                -> jong ieung                */
	0x11bd,  /* cho cieuc                -> jong cieuc                */
	0xd7f9,  /* cho ssangcieuc           -> jong ssangcieuc           */
	0x11be,  /* cho chieuch              -> jong chieuch              */
	0x11bf,  /* cho khieukh              -> jong khieukh              */
	0x11c0,  /* cho thieuth              -> jong thieuth              */
	0x11c1,  /* cho phieuph              -> jong phieuph              */
	0x11c2,  /* cho hieuh                -> jong hieuh                */
	0x11c5,  /* cho nieun-kiyeok         -> jong nieun-kiyeok         */
	0x11ff,  /* cho ssangnieun           -> jong ssangnieun           */
	0x11c6,  /* cho nieun-tikeut         -> jong nieun-tikeut         */
	0,       /* cho nieun-pieup                                      */
	0x11ca,  /* cho tikeut-kiyeok        -> jong tikeut-kiyeok        */
	0x11cd,  /* cho rieul-nieun          -> jong rieul-nieun          */
	0x11d0,  /* cho ssangrieul           -> jong ssangrieul           */
	0x11b6,  /* cho rieul-hieuh          -> jong rieul-hieuh          */
	0xd7dd,  /* cho kapyeounrieul        -> jong kapyeounrieul        */
	0x11dc,  /* cho mieum-pieup          -> jong mieum-pieup          */
	0x11e2,  /* cho kapyeounmieum        -> jong kapyeounmieum        */
	0,       /* cho pieup-kiyeok                                     */
	0,       /* cho pieup-nieun                                      */
	0xd7e3,  /* cho pieup-tikeut         -> jong pieup-tikeut         */
	0x11b9,  /* cho pieup-sios           -> jong pieup-sios           */
	0,       /* cho pieup-sios-kiyeok                                */
	0xd7e7,  /* cho pieup-sios-tikeut    -> jong pieup-sios-tikeut    */
	0,       /* cho pieup-sios-pieup                                 */
	0,       /* cho pieup-ssangsios                                  */
	0,       /* cho pieup-sios-cieuc                                 */
	0xd7e8,  /* cho pieup-cieuc          -> jong pieup-cieuc          */
	0xd7e9,  /* cho pieup-chieuch        -> jong pieup-chieuch        */
	0,       /* cho pieup-thieuth                                    */
	0x11e4,  /* cho pieup-phieuph        -> jong pieup-phieuph        */
	0x11e6,  /* cho kapyeounpieup        -> jong kapyeounpieup        */
	0,       /* cho kapyeounssangpieup                               */
	0x11e7,  /* cho sios-kiyeok          -> jong sios-kiyeok          */
	0,       /* cho sios-nieun                                       */
	0x11e8,  /* cho sios-tikeut          -> jong sios-tikeut          */
	0x11e9,  /* cho sios-rieul           -> jong sios-rieul           */
	0xd7ea,  /* cho sios-mieum           -> jong sios-mieum           */
	0x11ea,  /* cho sios-pieup           -> jong sios-pieup           */
	0,       /* cho sios-pieup-kiyeok                                */
	0,       /* cho sios-ssangsios                                   */
	0,       /* cho sios-ieung                                       */
	0xd7ef,  /* cho sios-cieuc           -> jong sios-cieuc           */
	0xd7f0,  /* cho sios-chieuch         -> jong sios-chieuch         */
	0,       /* cho sios-khieukh                                     */
	0xd7f1,  /* cho sios-thieuth         -> jong sios-thieuth         */
	0,       /* cho sios-phieuph                                     */
	0xd7f2,  /* cho sios-hieuh           -> jong sios-hieuh           */
	0,       /* cho chitueumsios                                     */
	0,       /* cho chitueumssangsios                                */
	0,       /* cho ceongchieumsios                                  */
	0,       /* cho ceongchieumssangsios                             */
	0x11eb,  /* cho pansios              -> jong pansios              */
	0x11ec,  /* cho ieung-kiyeok         -> jong ieung-kiyeok         */
	0,       /* cho ieung-tikeut                                     */
	0,       /* cho ieung-mieum                                      */
	0,       /* cho ieung-pieup                                      */
	0,       /* cho ieung-sios                                       */
	0,       /* cho ieung-pansios                                    */
	0x11ee,  /* cho ssangieung           -> jong ssangieung           */
	0,       /* cho ieung-cieuc                                      */
	0,       /* cho ieung-chieuch                                    */
	0,       /* cho ieung-thieuth                                    */
	0,       /* cho ieung-phieuph                                    */
	0x11f0,  /* cho yesieung             -> jong yesieung             */
	0,       /* cho cieuc-ieung                                      */
	0,       /* cho chitueumcieuc                                    */
	0,       /* cho chitueumssangcieuc                               */
	0,       /* cho ceongchieumcieuc                                 */
	0,       /* cho ceongchieumssangcieuc                            */
	0,       /* cho chieuch-khieukh                                  */
	0,       /* cho chieuch-hieuh                                    */
	0,       /* cho chitueumchieuch                                  */
	0,       /* cho ceongchieumchieuch                               */
	0x11f3,  /* cho phieuph-pieup        -> jong phieuph-pieup        */
	0x11f4,  /* cho kapyeounphieuph      -> jong kapyeounphieuph      */
	0,       /* cho ssanghieuh                                       */
	0x11f9,  /* cho yeorinhieuh          -> jong yeorinhieuh          */
	0,       /* cho kiyeok-tikeut                                    */
	0x11c7,  /* cho nieun-sios           -> jong nieun-sios           */
	0x11ac,  /* cho nieun-cieuc          -> jong nieun-cieuc          */
	0x11ad,  /* cho nieun-hieuh          -> jong nieun-hieuh          */
	0x11cb,  /* cho tikeut-rieul         -> jong tikeut-rieul         */
	0,       /* cho filler                                           */
    };

    static const ucschar table_ext_a[] = {
	0,       /* cho tikeut-mieum                                     */
	0xd7cf,  /* cho tikeut-pieup         -> jong tikeut-pieup         */
	0xd7d0,  /* cho tikeut-sios          -> jong tikeut-sios          */
	0xd7d2,  /* cho tikeut-cieuc         -> jong tikeut-cieuc         */
	0x11b0,  /* cho rieul-kiyeok         -> jong rieul-kiyeok         */
	0xd7d5,  /* cho rieul-ssangkiyeok    -> jong rieul-ssangkiyeok    */
	0x11ce,  /* cho rieul-tikeut         -> jong rieul-tikeut         */
	0,       /* cho rieul-ssangtikeut                                */
	0x11b1,  /* cho rieul-mieum          -> jong rieul-mieum          */
	0x11b2,  /* cho rieul-pieup          -> jong rieul-pieup          */
	0,       /* cho rieul-ssangpieup                                 */
	0x11d5,  /* cho rieul-kapyeounpieup  -> jong rieul-kapyeounpieup  */
	0x11b3,  /* cho rieul-sios           -> jong rieul-sios           */
	0,       /* cho rieul-cieuc                                      */
	0x11d8,  /* cho rieul-khieukh        -> jong rieul-khieukh        */
	0x11da,  /* cho mieum-kiyeok         -> jong mieum-kiyeok         */
	0,       /* cho mieum-tikeut                                     */
	0x11dd,  /* cho mieum-sios           -> jong mieum-sios           */
	0,       /* cho pieup-sios-thieuth                               */
	0,       /* cho pieup-khieukh                                    */
	0x11e5,  /* cho pieup-hieuh          -> jong pieup-hieuh          */
	0,       /* cho ssangsios-pieup                                  */
	0,       /* cho ieung-rieul                                      */
	0,       /* cho ieung-hieuh                                      */
	0,       /* cho ssangcieuc-hieuh                                 */
	0,       /* cho ssangthieuth                                     */
	0,       /* cho phieuph-hieuh                                    */
	0,       /* cho hieuh-sios                                       */
	0,       /* cho ssangyeorinhieuh                                 */
    };

    if (c >= 0x1100 && c <= 0x115e)
	return table[c - 0x1100];
    else if (c >= 0xa960 && c <= 0xa97c)
	return table_ext_a[c - 0xa960];

    return 0;
}

ucschar
hangul_jongseong_to_choseong(ucschar c)
{
    static const ucschar table[] = {
	0x1100,  /* jong kiyeok               -> cho kiyeok               */
	0x1101,  /* jong ssangkiyeok          -> cho ssangkiyeok          */
	0,       /* jong kiyeok-sios                                      */
	0x1102,  /* jong nieun                -> cho nieun                */
	0x115c,  /* jong nieun-cieuc          -> cho nieun-cieuc          */
	0x115d,  /* jong nieun-hieuh          -> cho nieun-hieuh          */
	0x1103,  /* jong tikeut               -> cho tikeut               */
	0x1105,  /* jong rieul                -> cho rieul                */
	0xa964,  /* jong rieul-kiyeok         -> cho rieul-kiyeok         */
	0xa968,  /* jong rieul-mieum          -> cho rieul-mieum          */
	0xa969,  /* jong rieul-pieup          -> cho rieul-pieup          */
	0xa96c,  /* jong rieul-sios           -> cho rieul-sios           */
	0,       /* jong rieul-thieuth                                    */
	0,       /* jong rieul-phieuph                                    */
	0x111a,  /* jong rieul-hieuh          -> cho rieul-hieuh          */
	0x1106,  /* jong mieum                -> cho mieum                */
	0x1107,  /* jong pieup                -> cho pieup                */
	0x1121,  /* jong pieup-sios           -> cho pieup-sios           */
	0x1109,  /* jong sios                 -> cho sios                 */
	0x110a,  /* jong ssangsios            -> cho ssangsios            */
	0x110b,  /* jong ieung                -> cho ieung                */
	0x110c,  /* jong cieuc                -> cho cieuc                */
	0x110e,  /* jong chieuch              -> cho chieuch              */
	0x110f,  /* jong khieukh              -> cho khieukh              */
	0x1110,  /* jong thieuth              -> cho thieuth              */
	0x1111,  /* jong phieuph              -> cho phieuph              */
	0x1112,  /* jong hieuh                -> cho hieuh                */
	0,       /* jong kiyeok-rieul                                     */
	0,       /* jong kiyeok-sios-kiyeok                               */
	0x1113,  /* jong nieun-kiyeok         -> cho nieun-kiyeok         */
	0x1115,  /* jong nieun-tikeut         -> cho nieun-tikeut         */
	0x115b,  /* jong nieun-sios           -> cho nieun-sios           */
	0,       /* jong nieun-pansios                                    */
	0,       /* jong nieun-thieuth                                    */
	0x1117,  /* jong tikeut-kiyeok        -> cho tikeut-kiyeok        */
	0x115e,  /* jong tikeut-rieul         -> cho tikeut-rieul         */
	0,       /* jong rieul-kiyeok-sios                                */
	0x1118,  /* jong rieul-nieun          -> cho rieul-nieun          */
	0xa966,  /* jong rieul-tikeut         -> cho rieul-tikeut         */
	0,       /* jong rieul-tikeut-hieuh                               */
	0x1119,  /* jong ssangrieul           -> cho ssangrieul           */
	0,       /* jong rieul-mieum-kiyeok                               */
	0,       /* jong rieul-mieum-sios                                 */
	0,       /* jong rieul-pieup-sios                                 */
	0,       /* jong rieul-pieup-hieuh                                */
	0xa96b,  /* jong rieul-kapyeounpieup  -> cho rieul-kapyeounpieup  */
	0,       /* jong rieul-ssangsios                                  */
	0,       /* jong rieul-pansios                                    */
	0xa96e,  /* jong rieul-khieukh        -> cho rieul-khieukh        */
	0,       /* jong rieul-yeorinhieuh                                */
	0xa96f,  /* jong mieum-kiyeok         -> cho mieum-kiyeok         */
	0,       /* jong mieum-rieul                                      */
	0x111c,  /* jong mieum-pieup          -> cho mieum-pieup          */
	0xa971,  /* jong mieum-sios           -> cho mieum-sios           */
	0,       /* jong mieum-ssangsios                                  */
	0,       /* jong mieum-pansios                                    */
	0,       /* jong mieum-chieuch                                    */
	0,       /* jong mieum-hieuh                                      */
	0x111d,  /* jong kapyeounmieum        -> cho kapyeounmieum        */
	0,       /* jong pieup-rieul                                      */
	0x112a,  /* jong pieup-phieuph        -> cho pieup-phieuph        */
	0xa974,  /* jong pieup-hieuh          -> cho pieup-hieuh          */
	0x112b,  /* jong kapyeounpieup        -> cho kapyeounpieup        */
	0x112d,  /* jong sios-kiyeok          -> cho sios-kiyeok          */
	0x112f,  /* jong sios-tikeut          -> cho sios-tikeut          */
	0x1130,  /* jong sios-rieul           -> cho sios-rieul           */
	0x1132,  /* jong sios-pieup           -> cho sios-pieup           */
	0x1140,  /* jong pansios              -> cho pansios              */
	0x1141,  /* jong ieung-kiyeok         -> cho ieung-kiyeok         */
	0,       /* jong ieung-ssangkiyeok                                */
	0x1147,  /* jong ssangieung           -> cho ssangieung           */
	0,       /* jong ieung-khieukh                                    */
	0x114c,  /* jong yesieung             -> cho yesieung             */
	0,       /* jong yesieung-sios                                    */
	0,       /* jong yesieung-pansios                                 */
	0x1156,  /* jong phieuph-pieup        -> cho phieuph-pieup        */
	0x1157,  /* jong kapyeounphieuph      -> cho kapyeounphieuph      */
	0,       /* jong hieuh-nieun                                      */
	0,       /* jong hieuh-rieul                                      */
	0,       /* jong hieuh-mieum                                      */
	0,       /* jong hieuh-pieup                                      */
	0x1159,  /* jong yeorinhieuh          -> cho yeorinhieuh          */
	0,       /* jong kiyeok-nieun                                     */
	0,       /* jong kiyeok-pieup                                     */
	0,       /* jong kiyeok-chieuch                                   */
	0,       /* jong kiyeok-khieukh                                   */
	0,       /* jong kiyeok-hieuh                                     */
	0x1114,  /* jong ssangnieun           -> cho ssangnieun           */
    };

    static const ucschar table_ext_b[] = {
	0,       /* jong nieun-rieul                                      */
	0,       /* jong nieun-chieuch                                    */
	0x1104,  /* jong ssangtikeut          -> cho ssangtikeut          */
	0,       /* jong ssangtikeut-pieup                                */
	0xa961,  /* jong tikeut-pieup         -> cho tikeut-pieup         */
	0xa962,  /* jong tikeut-sios          -> cho tikeut-sios          */
	0,       /* jong tikeut-sios-kiyeok                               */
	0xa963,  /* jong tikeut-cieuc         -> cho tikeut-cieuc         */
	0,       /* jong tikeut-chieuch                                   */
	0,       /* jong tikeut-thieuth                                   */
	0xa965,  /* jong rieul-ssangkiyeok    -> cho rieul-ssangkiyeok    */
	0,       /* jong rieul-kiyeok-hieuh                               */
	0,       /* jong ssangrieul-khieukh                               */
	0,       /* jong rieul-mieum-hieuh                                */
	0,       /* jong rieul-pieup-tikeut                               */
	0,       /* jong rieul-pieup-phieuph                              */
	0,       /* jong rieul-yesieung                                   */
	0,       /* jong rieul-yeorinhieuh-hieuh                          */
	0x111b,  /* jong kapyeounrieul        -> cho kapyeounrieul        */
	0,       /* jong mieum-nieun                                      */
	0,       /* jong mieum-ssangnieun                                 */
	0,       /* jong ssangmieum                                       */
	0,       /* jong mieum-pieup-sios                                 */
	0,       /* jong mieum-cieuc                                      */
	0x1120,  /* jong pieup-tikeut         -> cho pieup-tikeut         */
	0,       /* jong pieup-rieul-phieuph                              */
	0,       /* jong pieup-mieum                                      */
	0x1108,  /* jong ssangpieup           -> cho ssangpieup           */
	0x1123,  /* jong pieup-sios-tikeut    -> cho pieup-sios-tikeut    */
	0x1127,  /* jong pieup-cieuc          -> cho pieup-cieuc          */
	0x1128,  /* jong pieup-chieuch        -> cho pieup-chieuch        */
	0x1131,  /* jong sios-mieum           -> cho sios-mieum           */
	0,       /* jong sios-kapyeounpieup                               */
	0,       /* jong ssangsios-kiyeok                                 */
	0,       /* jong ssangsios-tikeut                                 */
	0,       /* jong sios-pansios                                     */
	0x1136,  /* jong sios-cieuc           -> cho sios-cieuc           */
	0x1137,  /* jong sios-chieuch         -> cho sios-chieuch         */
	0x1139,  /* jong sios-thieuth         -> cho sios-thieuth         */
	0x113b,  /* jong sios-hieuh           -> cho sios-hieuh           */
	0,       /* jong pansios-pieup                                    */
	0,       /* jong pansios-kapyeounpieup                            */
	0,       /* jong yesieung-mieum                                   */
	0,       /* jong yesieung-hieuh                                   */
	0,       /* jong cieuc-pieup                                      */
	0,       /* jong cieuc-ssangpieup                                 */
	0x110d,  /* jong ssangcieuc           -> cho ssangcieuc           */
	0,       /* jong phieuph-sios                                     */
	0,       /* jong phieuph-thieuth                                  */
    };

    if (c >= 0x11a8 && c <= 0x11ff)
	return table[c - 0x11a8];
    else if (c >= 0xd7cb && c <= 0xd7fb)
	return table_ext_b[c - 0xd7cb];

    return 0;
}

void
hangul_jongseong_dicompose(ucschar c, ucschar* jong, ucschar* cho)
{
    static ucschar table[][2] = {
    { 0,      0x1100 }, /* jong kiyeok	      = cho  kiyeok               */
    { 0x11a8, 0x1100 }, /* jong ssangkiyeok   = jong kiyeok + cho kiyeok  */
    { 0x11a8, 0x1109 }, /* jong kiyeok-sios   = jong kiyeok + cho sios    */
    { 0,      0x1102 }, /* jong nieun	      = cho  nieun                */
    { 0x11ab, 0x110c }, /* jong nieun-cieuc   = jong nieun  + cho cieuc   */
    { 0x11ab, 0x1112 }, /* jong nieun-hieuh   = jong nieun  + cho hieuh   */
    { 0,      0x1103 }, /* jong tikeut	      = cho  tikeut               */
    { 0,      0x1105 }, /* jong rieul         = cho  rieul                */
    { 0x11af, 0x1100 }, /* jong rieul-kiyeok  = jong rieul  + cho kiyeok  */
    { 0x11af, 0x1106 }, /* jong rieul-mieum   = jong rieul  + cho mieum   */
    { 0x11af, 0x1107 }, /* jong rieul-pieup   = jong rieul  + cho pieup   */
    { 0x11af, 0x1109 }, /* jong rieul-sios    = jong rieul  + cho sios    */
    { 0x11af, 0x1110 }, /* jong rieul-thieuth = jong rieul  + cho thieuth */
    { 0x11af, 0x1111 }, /* jong rieul-phieuph = jong rieul  + cho phieuph */
    { 0x11af, 0x1112 }, /* jong rieul-hieuh   = jong rieul  + cho hieuh   */
    { 0,      0x1106 }, /* jong mieum         = cho  mieum                */
    { 0,      0x1107 }, /* jong pieup         = cho  pieup                */
    { 0x11b8, 0x1109 }, /* jong pieup-sios    = jong pieup  + cho sios    */
    { 0,      0x1109 }, /* jong sios          = cho  sios                 */
    { 0x11ba, 0x1109 }, /* jong ssangsios     = jong sios   + cho sios    */
    { 0,      0x110b }, /* jong ieung         = cho  ieung                */
    { 0,      0x110c }, /* jong cieuc         = cho  cieuc                */
    { 0,      0x110e }, /* jong chieuch       = cho  chieuch              */
    { 0,      0x110f }, /* jong khieukh       = cho  khieukh              */
    { 0,      0x1110 }, /* jong thieuth       = cho  thieuth              */
    { 0,      0x1111 }, /* jong phieuph       = cho  phieuph              */
    { 0,      0x1112 }  /* jong hieuh         = cho  hieuh                */
    };

    *jong = table[c - 0x11a8][0];
    *cho  = table[c - 0x11a8][1];
}

static int
hangul_jongseong_get_ncomponent(ucschar jong)
{
    static const char table[] = {
	1, /* kiyeok                            */
	2, /* ssangkiyeok                       */
	2, /* kiyeok-sios                       */
	1, /* nieun                             */
	2, /* nieun-cieuc                       */
	2, /* nieun-hieuh                       */
	1, /* tikeut                            */
	1, /* rieul                             */
	2, /* rieul-kiyeok                      */
	2, /* rieul-mieum                       */
	2, /* rieul-pieup                       */
	2, /* rieul-sios                        */
	2, /* rieul-thieuth                     */
	2, /* rieul-phieuph                     */
	2, /* rieul-hieuh                       */
	1, /* mieum                             */
	1, /* pieup                             */
	2, /* pieup-sios                        */
	1, /* sios                              */
	2, /* ssangsios                         */
	1, /* ieung                             */
	1, /* cieuc                             */
	1, /* chieuch                           */
	1, /* khieukh                           */
	1, /* thieuth                           */
	1, /* phieuph                           */
	1, /* hieuh                             */
	2, /* kiyeok-rieul                      */
	3, /* kiyeok-sios-kiyeok                */
	2, /* nieun-kiyeok                      */
	2, /* nieun-tikeut                      */
	2, /* nieun-sios                        */
	2, /* nieun-pansios                     */
	2, /* nieun-thieuth                     */
	2, /* tikeut-kiyeok                     */
	2, /* tikeut-rieul                      */
	3, /* rieul-kiyeok-sios                 */
	2, /* rieul-nieun                       */
	2, /* rieul-tikeut                      */
	3, /* rieul-tikeut-hieuh                */
	2, /* ssangrieul                        */
	3, /* rieul-mieum-kiyeok                */
	3, /* rieul-mieum-sios                  */
	3, /* rieul-pieup-sios                  */
	3, /* rieul-pieup-hieuh                 */
	3, /* rieul-kapyeounpieup               */
	3, /* rieul-ssangsios                   */
	2, /* rieul-pansios                     */
	2, /* rieul-khieukh                     */
	2, /* rieul-yeorinhieuh                 */
	2, /* mieum-kiyeok                      */
	2, /* mieum-rieul                       */
	2, /* mieum-pieup                       */
	2, /* mieum-sios                        */
	3, /* mieum-ssangsios                   */
	2, /* mieum-pansios                     */
	2, /* mieum-chieuch                     */
	2, /* mieum-hieuh                       */
	2, /* kapyeounmieum                     */
	2, /* pieup-rieul                       */
	2, /* pieup-phieuph                     */
	2, /* pieup-hieuh                       */
	2, /* kapyeounpieup                     */
	2, /* sios-kiyeok                       */
	2, /* sios-tikeut                       */
	2, /* sios-rieul                        */
	2, /* sios-pieup                        */
	1, /* pansios                           */
	2, /* ieung-kiyeok                      */
	3, /* ieung-ssangkiyeok                 */
	2, /* ssangieung                        */
	2, /* ieung-khieukh                     */
	1, /* yesieung                          */
	2, /* yesieung-sios                     */
	2, /* yesieung-pansios                  */
	2, /* phieuph-pieup                     */
	2, /* kapyeounphieuph                   */
	2, /* hieuh-nieun                       */
	2, /* hieuh-rieul                       */
	2, /* hieuh-mieum                       */
	2, /* hieuh-pieup                       */
	1, /* yeorinhieuh                       */
	2, /* kiyeok-nieun                      */
	2, /* kiyeok-pieup                      */
	2, /* kiyeok-chieuch                    */
	2, /* kiyeok-khieukh                    */
	2, /* kiyeok-hieuh                      */
	2, /* ssangnieun                        */
    };

    static const char table_ext_b[] = {
	2, /* nieun-rieul                       */
	2, /* nieun-chieuch                     */
	2, /* ssangtikeut                       */
	3, /* ssangtikeut-pieup                 */
	2, /* tikeut-pieup                      */
	2, /* tikeut-sios                       */
	3, /* tikeut-sios-kiyeok                */
	2, /* tikeut-cieuc                      */
	2, /* tikeut-chieuch                    */
	2, /* tikeut-thieuth                    */
	3, /* rieul-ssangkiyeok                 */
	3, /* rieul-kiyeok-hieuh                */
	3, /* ssangrieul-khieukh                */
	3, /* rieul-mieum-hieuh                 */
	3, /* rieul-pieup-tikeut                */
	3, /* rieul-pieup-phieuph               */
	2, /* rieul-yesieung                    */
	3, /* rieul-yeorinhieuh-hieuh           */
	2, /* kapyeounrieul                     */
	2, /* mieum-nieun                       */
	3, /* mieum-ssangnieun                  */
	2, /* ssangmieum                        */
	3, /* mieum-pieup-sios                  */
	2, /* mieum-cieuc                       */
	2, /* pieup-tikeut                      */
	3, /* pieup-rieul-phieuph               */
	2, /* pieup-mieum                       */
	2, /* ssangpieup                        */
	3, /* pieup-sios-tikeut                 */
	2, /* pieup-cieuc                       */
	2, /* pieup-chieuch                     */
	2, /* sios-mieum                        */
	3, /* sios-kapyeounpieup                */
	3, /* ssangsios-kiyeok                  */
	3, /* ssangsios-tikeut                  */
	2, /* sios-pansios                      */
	2, /* sios-cieuc                        */
	2, /* sios-chieuch                      */
	2, /* sios-thieuth                      */
	2, /* sios-hieuh                        */
	2, /* pansios-pieup                     */
	3, /* pansios-kapyeounpieup             */
	2, /* yesieung-mieum                    */
	2, /* yesieung-hieuh                    */
	2, /* cieuc-pieup                       */
	3, /* cieuc-ssangpieup                  */
	2, /* ssangcieuc                        */
	2, /* phieuph-sios                      */
	2, /* phieuph-thieuth                   */
    };

    if (jong >= 0x11a8 && jong <= 0x11ff) {
	return table[jong - 0x11a8];
    } else if (jong >= 0xd7cb && jong <= 0xd7fb) {
	return table_ext_b[jong - 0xd7cb];
    }

    return 0;
}

ucschar
hangul_jongseong_get_diff(ucschar prevjong, ucschar jong)
{
    static const ucschar table[][2] = {
	{ 0x1100, 0x1100 }, /* kiyeok: kiyeok, kiyeok                      */
	{ 0x1100, 0x1101 }, /* ssangkiyeok: kiyeok, ssangkiyeok            */
	{ 0x1109, 0      }, /* kiyeok-sios: sios                           */
	{ 0x1102, 0x1102 }, /* nieun: nieun, nieun                         */
	{ 0x110c, 0x115c }, /* nieun-cieuc: cieuc, nieun-cieuc             */
	{ 0x1112, 0x115d }, /* nieun-hieuh: hieuh, nieun-hieuh             */
	{ 0x1103, 0x1103 }, /* tikeut: tikeut, tikeut                      */
	{ 0x1105, 0x1105 }, /* rieul: rieul, rieul                         */
	{ 0x1100, 0xa964 }, /* rieul-kiyeok: kiyeok, rieul-kiyeok          */
	{ 0x1106, 0xa968 }, /* rieul-mieum: mieum, rieul-mieum             */
	{ 0x1107, 0xa969 }, /* rieul-pieup: pieup, rieul-pieup             */
	{ 0x1109, 0xa96c }, /* rieul-sios: sios, rieul-sios                */
	{ 0x1110, 0      }, /* rieul-thieuth: thieuth                      */
	{ 0x1111, 0      }, /* rieul-phieuph: phieuph                      */
	{ 0x1112, 0x111a }, /* rieul-hieuh: hieuh, rieul-hieuh             */
	{ 0x1106, 0x1106 }, /* mieum: mieum, mieum                         */
	{ 0x1107, 0x1107 }, /* pieup: pieup, pieup                         */
	{ 0x1109, 0x1121 }, /* pieup-sios: sios, pieup-sios                */
	{ 0x1109, 0x1109 }, /* sios: sios, sios                            */
	{ 0x1109, 0x110a }, /* ssangsios: sios, ssangsios                  */
	{ 0x110b, 0x110b }, /* ieung: ieung, ieung                         */
	{ 0x110c, 0x110c }, /* cieuc: cieuc, cieuc                         */
	{ 0x110e, 0x110e }, /* chieuch: chieuch, chieuch                   */
	{ 0x110f, 0x110f }, /* khieukh: khieukh, khieukh                   */
	{ 0x1110, 0x1110 }, /* thieuth: thieuth, thieuth                   */
	{ 0x1111, 0x1111 }, /* phieuph: phieuph, phieuph                   */
	{ 0x1112, 0x1112 }, /* hieuh: hieuh, hieuh                         */
	{ 0x1105, 0      }, /* kiyeok-rieul: rieul                         */
	{ 0x1100, 0x112d }, /* kiyeok-sios-kiyeok: kiyeok, sios-kiyeok     */
	{ 0x1100, 0x1113 }, /* nieun-kiyeok: kiyeok, nieun-kiyeok          */
	{ 0x1103, 0x1115 }, /* nieun-tikeut: tikeut, nieun-tikeut          */
	{ 0x1109, 0x115b }, /* nieun-sios: sios, nieun-sios                */
	{ 0x1140, 0      }, /* nieun-pansios: pansios                      */
	{ 0x1110, 0      }, /* nieun-thieuth: thieuth                      */
	{ 0x1100, 0x1117 }, /* tikeut-kiyeok: kiyeok, tikeut-kiyeok        */
	{ 0x1105, 0x115e }, /* tikeut-rieul: rieul, tikeut-rieul           */
	{ 0x1109, 0      }, /* rieul-kiyeok-sios: sios                     */
	{ 0x1102, 0x1118 }, /* rieul-nieun: nieun, rieul-nieun             */
	{ 0x1103, 0xa966 }, /* rieul-tikeut: tikeut, rieul-tikeut          */
	{ 0x1112, 0      }, /* rieul-tikeut-hieuh: hieuh                   */
	{ 0x1105, 0x1119 }, /* ssangrieul: rieul, ssangrieul               */
	{ 0x1100, 0xa96f }, /* rieul-mieum-kiyeok: kiyeok, mieum-kiyeok    */
	{ 0x1109, 0xa971 }, /* rieul-mieum-sios: sios, mieum-sios          */
	{ 0x1109, 0x1121 }, /* rieul-pieup-sios: sios, pieup-sios          */
	{ 0x1112, 0xa974 }, /* rieul-pieup-hieuh: hieuh, pieup-hieuh       */
	{ 0x110b, 0x112b }, /* rieul-kapyeounpieup: ieung, kapyeounpieup   */
	{ 0x1109, 0x110a }, /* rieul-ssangsios: sios, ssangsios            */
	{ 0x1140, 0      }, /* rieul-pansios: pansios                      */
	{ 0x110f, 0xa96e }, /* rieul-khieukh: khieukh, rieul-khieukh       */
	{ 0x1159, 0      }, /* rieul-yeorinhieuh: yeorinhieuh              */
	{ 0x1100, 0xa96f }, /* mieum-kiyeok: kiyeok, mieum-kiyeok          */
	{ 0x1105, 0      }, /* mieum-rieul: rieul                          */
	{ 0x1107, 0x111c }, /* mieum-pieup: pieup, mieum-pieup             */
	{ 0x1109, 0xa971 }, /* mieum-sios: sios, mieum-sios                */
	{ 0x1109, 0x110a }, /* mieum-ssangsios: sios, ssangsios            */
	{ 0x1140, 0      }, /* mieum-pansios: pansios                      */
	{ 0x110e, 0      }, /* mieum-chieuch: chieuch                      */
	{ 0x1112, 0      }, /* mieum-hieuh: hieuh                          */
	{ 0x110b, 0x111d }, /* kapyeounmieum: ieung, kapyeounmieum         */
	{ 0x1105, 0      }, /* pieup-rieul: rieul                          */
	{ 0x1111, 0x112a }, /* pieup-phieuph: phieuph, pieup-phieuph       */
	{ 0x1112, 0xa974 }, /* pieup-hieuh: hieuh, pieup-hieuh             */
	{ 0x110b, 0x112b }, /* kapyeounpieup: ieung, kapyeounpieup         */
	{ 0x1100, 0x112d }, /* sios-kiyeok: kiyeok, sios-kiyeok            */
	{ 0x1103, 0x112f }, /* sios-tikeut: tikeut, sios-tikeut            */
	{ 0x1105, 0x1130 }, /* sios-rieul: rieul, sios-rieul               */
	{ 0x1107, 0x1132 }, /* sios-pieup: pieup, sios-pieup               */
	{ 0x1140, 0x1140 }, /* pansios: pansios, pansios                   */
	{ 0x1100, 0      }, /* yesieung-kiyeok: kiyeok                     */
	{ 0x1100, 0x1101 }, /* yesieung-ssangkiyeok: kiyeok, ssangkiyeok   */
	{ 0x114c, 0      }, /* ssangyesieung: yesieung                     */
	{ 0x110f, 0      }, /* yesieung-khieukh: khieukh                   */
	{ 0x114c, 0x114c }, /* yesieung: yesieung, yesieung                */
	{ 0x1109, 0      }, /* yesieung-sios: sios                         */
	{ 0x1140, 0      }, /* yesieung-pansios: pansios                   */
	{ 0x1107, 0x1156 }, /* phieuph-pieup: pieup, phieuph-pieup         */
	{ 0x110b, 0x1157 }, /* kapyeounphieuph: ieung, kapyeounphieuph     */
	{ 0x1102, 0      }, /* hieuh-nieun: nieun                          */
	{ 0x1105, 0      }, /* hieuh-rieul: rieul                          */
	{ 0x1106, 0      }, /* hieuh-mieum: mieum                          */
	{ 0x1107, 0      }, /* hieuh-pieup: pieup                          */
	{ 0x1159, 0x1159 }, /* yeorinhieuh: yeorinhieuh, yeorinhieuh       */
	{ 0x1102, 0      }, /* kiyeok-nieun: nieun                         */
	{ 0x1107, 0      }, /* kiyeok-pieup: pieup                         */
	{ 0x110e, 0      }, /* kiyeok-chieuch: chieuch                     */
	{ 0x110f, 0      }, /* kiyeok-khieukh: khieukh                     */
	{ 0x1112, 0      }, /* kiyeok-hieuh: hieuh                         */
	{ 0x1102, 0x1114 }, /* ssangnieun: nieun, ssangnieun               */
    };

    static const ucschar table_ext_b[][2] = {
	{ 0x1105, 0      }, /* nieun-rieul: rieul                          */
	{ 0x110e, 0      }, /* nieun-chieuch: chieuch                      */
	{ 0x1103, 0x1104 }, /* ssangtikeut: tikeut, ssangtikeut            */
	{ 0x1107, 0xa961 }, /* ssangtikeut-pieup: pieup, tikeut-pieup      */
	{ 0x1107, 0xa961 }, /* tikeut-pieup: pieup, tikeut-pieup           */
	{ 0x1109, 0xa962 }, /* tikeut-sios: sios, tikeut-sios              */
	{ 0x1100, 0x112d }, /* tikeut-sios-kiyeok: kiyeok, sios-kiyeok     */
	{ 0x110c, 0xa963 }, /* tikeut-cieuc: cieuc, tikeut-cieuc           */
	{ 0x110e, 0      }, /* tikeut-chieuch: chieuch                     */
	{ 0x1110, 0      }, /* tikeut-thieuth: thieuth                     */
	{ 0x1100, 0x1101 }, /* rieul-ssangkiyeok: kiyeok, ssangkiyeok      */
	{ 0x1112, 0      }, /* rieul-kiyeok-hieuh: hieuh                   */
	{ 0x110f, 0xa96e }, /* ssangrieul-khieukh: khieukh, rieul-khieukh  */
	{ 0x1112, 0      }, /* rieul-mieum-hieuh: hieuh                    */
	{ 0x1103, 0x1120 }, /* rieul-pieup-tikeut: tikeut, pieup-tikeut    */
	{ 0x1111, 0x112a }, /* rieul-pieup-phieuph: phieuph, pieup-phieuph */
	{ 0x114c, 0      }, /* rieul-yesieung: yesieung                    */
	{ 0x1112, 0      }, /* rieul-yeorinhieuh-hieuh: hieuh              */
	{ 0x110b, 0x111b }, /* kapyeounrieul: ieung, kapyeounrieul         */
	{ 0x1102, 0      }, /* mieum-nieun: nieun                          */
	{ 0x1102, 0x1114 }, /* mieum-ssangnieun: nieun, ssangnieun         */
	{ 0x1106, 0      }, /* ssangmieum: mieum                           */
	{ 0x1109, 0x1121 }, /* mieum-pieup-sios: sios, pieup-sios          */
	{ 0x110c, 0      }, /* mieum-cieuc: cieuc                          */
	{ 0x1103, 0x1120 }, /* pieup-tikeut: tikeut, pieup-tikeut          */
	{ 0x1111, 0      }, /* pieup-rieul-phieuph: phieuph                */
	{ 0x1106, 0      }, /* pieup-mieum: mieum                          */
	{ 0x1107, 0x1108 }, /* ssangpieup: pieup, ssangpieup               */
	{ 0x1103, 0x112f }, /* pieup-sios-tikeut: tikeut, sios-tikeut      */
	{ 0x110c, 0x1127 }, /* pieup-cieuc: cieuc, pieup-cieuc             */
	{ 0x110e, 0x1128 }, /* pieup-chieuch: chieuch, pieup-chieuch       */
	{ 0x1106, 0x1131 }, /* sios-mieum: mieum, sios-mieum               */
	{ 0x110b, 0x112b }, /* sios-kapyeounpieup: ieung, kapyeounpieup    */
	{ 0x1100, 0x112d }, /* ssangsios-kiyeok: kiyeok, sios-kiyeok       */
	{ 0x1103, 0x112f }, /* ssangsios-tikeut: tikeut, sios-tikeut       */
	{ 0x1140, 0      }, /* sios-pansios: pansios                       */
	{ 0x110c, 0x1136 }, /* sios-cieuc: cieuc, sios-cieuc               */
	{ 0x110e, 0x1137 }, /* sios-chieuch: chieuch, sios-chieuch         */
	{ 0x1110, 0x1139 }, /* sios-thieuth: thieuth, sios-thieuth         */
	{ 0x1112, 0x113b }, /* sios-hieuh: hieuh, sios-hieuh               */
	{ 0x1107, 0      }, /* pansios-pieup: pieup                        */
	{ 0x110b, 0x112b }, /* pansios-kapyeounpieup: ieung, kapyeounpieup */
	{ 0x1106, 0      }, /* yesieung-mieum: mieum                       */
	{ 0x1112, 0      }, /* yesieung-hieuh: hieuh                       */
	{ 0x1107, 0      }, /* cieuc-pieup: pieup                          */
	{ 0x1107, 0x1108 }, /* cieuc-ssangpieup: pieup, ssangpieup         */
	{ 0x110c, 0x110d }, /* ssangcieuc: cieuc, ssangcieuc               */
	{ 0x1109, 0      }, /* phieuph-sios: sios                          */
	{ 0x1110, 0      }, /* phieuph-thieuth: thieuth                    */
    };

    ucschar cho = 0;

    if (prevjong == 0) {
	cho = hangul_jongseong_to_choseong(jong);
    } else {
	int diff;
	int n1;
	int n2;

	n1 = hangul_jongseong_get_ncomponent(prevjong);
	n2 = hangul_jongseong_get_ncomponent(jong);

	diff = n2 - n1 - 1;
	if (diff >= 0 && diff < 2) {
	    if (jong >= 0x11a8 && jong <= 0x11ff) {
		cho = table[jong - 0x11a8][diff];
	    } else if (jong >= 0xd7cb && jong <= 0xd7fb) {
		cho = table_ext_b[jong - 0xd7cb][diff];
	    }
	} else if (diff == 2) {
	    cho = hangul_jongseong_to_choseong(jong);
	}
    }

    return cho;
}

/**
 * @ingroup hangulctype
 * @brief 자모 코드를 조합하여 한글 음절로 변환
 * @param choseong 초성이 될 UCS4 코드 값
 * @param jungseong 중성이 될 UCS4 코드 값
 * @param jongseong 종성이 될 UCS4 코드 값
 * @return @a choseong @a jungseong @a jongseong을 조합한 현대 한글 음절 코드,
 *         또는 0
 *
 * 이 함수는 @a choseong @a jungseong @a jongseong으로 주어진 코드 값을 각각
 * 초성, 중성, 종성으로 하는 현대 한글 음절 코드를 구한다.
 * @a choseong @a jungseong @a jongseong 이 조합 가능한 코드가 아니라면 
 * 0을 리턴한다. 종성이 없는 글자를 만들기 위해서는 jongseong에 0을 주면 된다.
 */
ucschar
hangul_jamo_to_syllable(ucschar choseong, ucschar jungseong, ucschar jongseong)
{
    ucschar c;

    /* we use 0x11a7 like a Jongseong filler */
    if (jongseong == 0)
	jongseong = 0x11a7;         /* Jongseong filler */

    if (!hangul_is_choseong_conjoinable(choseong))
	return 0;
    if (!hangul_is_jungseong_conjoinable(jungseong))
	return 0;
    if (!hangul_is_jongseong_conjoinable(jongseong))
	return 0;

    choseong  -= choseong_base;
    jungseong -= jungseong_base;
    jongseong -= jongseong_base;

    c = ((choseong * njungseong) + jungseong) * njongseong + jongseong
	+ syllable_base;
    return c;
}

/** @deprecated 이 함수 대신 hangul_jamo_to_syllable()을 사용한다. */
ucschar
hangul_jaso_to_syllable(ucschar choseong, ucschar jungseong, ucschar jongseong)
{
    return hangul_jamo_to_syllable(choseong, jungseong, jongseong);
}

/**
 * @ingroup hangulctype
 * @brief 음절을 자모로 분해
 * @param syllable 분해할 음절
 * @retval choseong 음절에서 초성 부분의 코드
 * @retval jungseong 음절에서 중성 부분의 코드
 * @retval jongseong 음절에서 종성 부분의 코드, 종성이 없으면 0을 반환한다
 * @return 없음
 *
 * 이 함수는 @a syllable 로 주어진 음절 코드를 분해하여 자모 코드를 반환한다.
 * 반환하는 값은 @a choseong, @a jungseong, @a jongseong 의 포인터에 대입하여
 * 리턴한다. 종성이 없는 음절인 경우에는 @a jongseong 에 0을 반환한다.
 */
void
hangul_syllable_to_jamo(ucschar syllable,
			ucschar* choseong,
			ucschar* jungseong,
			ucschar* jongseong)
{
    if (jongseong != NULL)
	*jongseong = 0;
    if (jungseong != NULL)
	*jungseong = 0;
    if (choseong != NULL)
	*choseong = 0;

    if (!hangul_is_syllable(syllable))
	return;

    syllable -= syllable_base;
    if (jongseong != NULL) {
	if (syllable % njongseong != 0)
	    *jongseong = jongseong_base + syllable % njongseong;
    }
    syllable /= njongseong;

    if (jungseong != NULL) {
	*jungseong = jungseong_base + syllable % njungseong;
    }
    syllable /= njungseong;

    if (choseong != NULL) {
	*choseong = choseong_base + syllable;
    }
}

/** @deprecated 이 함수 대신 hangul_syllable_to_jamo함수를 사용한다. */
void
hangul_syllable_to_jaso(ucschar syllable,
			ucschar* choseong,
			ucschar* jungseong,
			ucschar* jongseong)
{
    return hangul_syllable_to_jamo(syllable, choseong, jungseong, jongseong);
}

static inline bool 
is_syllable_boundary(ucschar prev, ucschar next)
{
    if (hangul_is_choseong(prev)) {
	if (hangul_is_choseong(next))
	    return false;
	if (hangul_is_jungseong(next))
	    return false;
	if (hangul_is_syllable(next))
	    return false;
	if (hangul_is_combining_mark(next))
	    return false;
	if (next == HANGUL_JUNGSEONG_FILLER)
	    return false;
    } else if (prev == HANGUL_CHOSEONG_FILLER) {
	if (hangul_is_jungseong(next))
	    return false;
	if (next == HANGUL_JUNGSEONG_FILLER)
	    return false;
    } else if (hangul_is_jungseong(prev)) {
	if (hangul_is_jungseong(next))
	    return false;
	if (hangul_is_jongseong(next))
	    return false;
	if (hangul_is_combining_mark(next))
	    return false;
    } else if (prev == HANGUL_JUNGSEONG_FILLER) {
	if (hangul_is_jongseong(next))
	    return false;
    } else if (hangul_is_jongseong(prev)) {
	if (hangul_is_jongseong(next))
	    return false;
	if (hangul_is_combining_mark(next))
	    return false;
    } else if (hangul_is_syllable(prev)) {
	if ((prev - syllable_base) % njongseong == 0) {
	    // 종성이 없는 음절: LV
	    if (hangul_is_jungseong(next))
		return false;
	    if (hangul_is_jongseong(next))
		return false;
	} else {
	    // 종성이 있는 음절: LVT
	    if (hangul_is_jongseong(next))
		return false;
	}
	if (hangul_is_combining_mark(next))
	    return false;
    }
    
    return true;
}

static inline ucschar
choseong_compress(ucschar a, ucschar b)
{
    if (a == 0)
	return b;

    if (a == 0x1100 && b == 0x1100)
	return 0x1101;
    if (a == 0x1103 && b == 0x1103)
	return 0x1104;
    if (a == 0x1107 && b == 0x1107)
	return 0x1108;
    if (a == 0x1109 && b == 0x1109)
	return 0x110A;
    if (a == 0x110c && b == 0x110c)
	return 0x110d;
    return 0;
}

static inline ucschar
jungseong_compress(ucschar a, ucschar b)
{
    if (a == 0)
	return b;

    if (a == 0x1169) {
	if (b == 0x1161)
	    return 0x116a;
	if (b == 0x1162)
	    return 0x116b;
	if (b == 0x1175)
	    return 0x116c;
    }
    if (a == 0x116e) {
	if (b == 0x1165)
	    return 0x116f;
	if (b == 0x1166)
	    return 0x1170;
	if (b == 0x1175)
	    return 0x1171;
    }
    if (b == 0x1175) {
	if (a == 0x1173)
	    return 0x1174;
	if (a == 0x1161)
	    return 0x1162;
	if (a == 0x1163)
	    return 0x1164;
	if (a == 0x1165)
	    return 0x1166;
	if (a == 0x1167)
	    return 0x1168;
    }

    return 0;
}

static inline ucschar
jongseong_compress(ucschar a, ucschar b)
{
    if (a == 0)
	return b;
    
    if (a == 0x11a8) {
	if (b == 0x11a8)
	    return 0x11a9;
	if (b == 0x11ba)
	    return 0x11aa;
    }
    if (a == 0x11ab) {
	if (b == 0x11b0)
	    return 0x11ab;
	if (b == 0x11c2)
	    return 0x11ad;
    }
    if (a == 0x11af) {
	if (b == 0x11a8)
	    return 0x11b0;
	if (b == 0x11b7)
	    return 0x11b1;
	if (b == 0x11b8)
	    return 0x11b2;
	if (b == 0x11ba)
	    return 0x11b3;
	if (b == 0x11c0)
	    return 0x11b4;
	if (b == 0x11c1)
	    return 0x11b5;
	if (b == 0x11c2)
	    return 0x11b6;
    }
    if (a == 0x11b8 && b == 0x11ba)
	return 0x11b9;
    if (a == 0x11ba && b == 0x11ba)
	return 0x11bb;

    return 0;
}

static inline ucschar
build_syllable(const ucschar* str, size_t len)
{
    int i;
    ucschar cho = 0, jung = 0, jong = 0;

    i = 0;
    while (i < len && hangul_is_choseong_conjoinable(str[i])) {
	cho = choseong_compress(cho, str[i]);
	if (cho == 0)
	    return 0;
	i++;
    }

    while (i < len && hangul_is_jungseong_conjoinable(str[i])) {
	jung = jungseong_compress(jung, str[i]);
	if (jung == 0)
	    return 0;
	i++;
    }

    while (i < len && hangul_is_jongseong_conjoinable(str[i])) {
	jong = jongseong_compress(jong, str[i]);
	if (jong == 0)
	    return 0;
	i++;
    }

    if (i < len)
	return 0;

    return hangul_jamo_to_syllable(cho, jung, jong);
}

/**
 * @ingroup hangulctype
 * @brief 한 음절에 해당하는 코드의 갯수를 구하는 함수
 * @param str 음절의 길이를 구할 스트링
 * @param max_len @a str 에서 읽을 길이의 제한값
 * @return 한 음절에 해당하는 코드의 갯수
 *
 * 이 함수는 @a str 에서 한 음절에 해당하는 코드의 갯수를 구한다. 
 * 한 음절에 해당하는 코드의 갯수가 @a max_len 보다 많다면 @a max_len 을 
 * 반환한다. 한 음절이라고 판단하는 기준은 L*V*T+ 패턴에 따른다. 이 패턴은
 * regular expression의 컨벤션을 따른 것으로, 1개 이상의 초성과 중성, 0개
 * 이상의 종성이 모인 자모 스트링을 한 음절로 인식한다는 뜻이다. 예를 들면
 * 다음과 같은 자모 스트링도 한 음절로 인식한다.
 *
 *  예) "ㅂ ㅂ ㅜ ㅔ ㄹ ㄱ" -> "쀍"
 * 
 * 따라서 위 경우에는 6을 반환하게 된다. 
 *
 * 일반적으로는 방점(U+302E, U+302F)까지 한 음절로 인식하겠지만, 이 함수는
 * 음절과 자모간 변환을 편리하게 하기 위해 구현된 것으로 방점은 다른 음절로 
 * 인식한다.
 *
 * @a str 이 자모 코드에 해당하지 않는 경우에는 1을 반환한다.
 *
 * 이 함수는 자모 스트링에서 총 음절의 갯수를 구하는 함수가 아님에 주의한다.
 */
int
hangul_syllable_len(const ucschar* str, int max_len)
{
    int i = 0;

    if (max_len == 0)
	return 0;

    if (str[i] != 0) {
	for (i = 1; i < max_len; i++) {
	    if (str[i] == 0)
		break;

	    if (is_syllable_boundary(str[i - 1], str[i]))
		break;
	}
    }

    return i;
}

/**
 * @ingroup hangulctype
 * @brief @a iter를 기준으로 이전 음절의 첫자모 글자에 대한 포인터를 구하는 함수
 * @param iter 현재 위치
 * @param begin 스트링의 시작위치, 포인터가 이동할 한계값
 * @return 이전 음절의 첫번째 자모에 대한 포인터
 *
 * 이 함수는 @a iter로 주어진 자모 스트링의 포인터를 기준으로 이전 음절의 
 * 첫번째 자모에 대한 포인터를 리턴한다. 음절을 찾기위해서 begin보다 
 * 앞쪽으로 이동하지 않는다. 
 *
 * 한 음절이라고 판단하는 기준은 L*V*T+M? 패턴에 따른다.
 */
const ucschar*
hangul_syllable_iterator_prev(const ucschar* iter, const ucschar* begin)
{
    if (iter > begin)
	iter--;

    while (iter > begin) {
	ucschar prev = iter[-1];
	ucschar curr = iter[0];
	if (is_syllable_boundary(prev, curr))
	    break;
	iter--;
    }

    return iter;
}

/**
 * @ingroup hangulctype
 * @brief @a iter를 기준으로 다음 음절의 첫자모 글자에 대한 포인터를 구하는 함수
 * @param iter 현재 위치
 * @param end 스트링의 끝위치, 포인터가 이동할 한계값
 * @return 다음 음절의 첫번째 자모에 대한 포인터
 *
 * 이 함수는 @a iter로 주어진 자모 스트링의 포인터를 기준으로 다음 음절의 
 * 첫번째 자모에 대한 포인터를 리턴한다. 음절을 찾기위해서 end를 넘어
 * 이동하지 않는다. 
 *
 * 한 음절이라고 판단하는 기준은 L*V*T+M? 패턴에 따른다.
 */
const ucschar*
hangul_syllable_iterator_next(const ucschar* iter, const ucschar* end)
{
    if (iter < end)
	iter++;

    while (iter < end) {
	ucschar prev = iter[-1];
	ucschar curr = iter[0];
	if (is_syllable_boundary(prev, curr))
	    break;
	iter++;
    }

    return iter;
}

/**
 * @ingroup hangulctype
 * @brief 자모 스트링을 음절 스트링으로 변환
 * @param dest 음절형으로 변환된 결과가 저장될 버퍼
 * @param destlen 결과를 저장할 버퍼의 길이(ucschar 코드 단위)
 * @param src 변환할 자모 스트링
 * @param srclen 변환할 자모 스트링의 길이(ucschar 코드 단위)
 * @return @a destlen 에 저장한 코드의 갯수
 *
 * 이 함수는 L+V+T*M? 패턴에 따라 자모 스트링 변환을 시도한다. 한 음절을 
 * 판단하는 기준은 @ref hangul_syllable_len 을 참조한다.
 * 만일 @a src 가 적절한 음절형태로 변환이 불가능한 경우에는 자모 스트링이
 * 그대로 복사된다.
 *
 * 이 함수는 자모 스트링 @a src 를 음절형으로 변환하여 @a dest 에 저장한다.
 * @a srclen 에 지정된 갯수만큼 읽고, @a destlen 에 지정된 길이 이상 쓰지
 * 않는다.  @a srclen 이 -1이라면 @a src 는 0으로 끝나는 스트링으로 가정하고
 * 0을 제외한 길이까지 변환을 시도한다. 따라서 변환된 결과 스트링은 0으로 
 * 끝나지 않는다. 만일 0으로 끝나는 스트링을 만들고 싶다면 다음과 같이 한다.
 *
 * @code
 * int n = hangul_jamos_to_syllables(dest, destlen, src, srclen);
 * dest[n] = 0;
 * @endcode
 */
int
hangul_jamos_to_syllables(ucschar* dest, int destlen, const ucschar* src, int srclen)
{
    ucschar* d;
    const ucschar* s;

    int inleft;
    int outleft;
    int n;

    if (srclen < 0) {
	s = src;
	while (*s != 0)
	    s++;
	srclen = s - src;
    }

    s = src;
    d = dest;
    inleft = srclen;
    outleft = destlen;

    n = hangul_syllable_len(s, inleft);
    while (n > 0 && inleft > 0 && outleft > 0) {
	ucschar c = build_syllable(s, n);
	if (c != 0) {
	    *d = c;
	    d++;
	    outleft--;
	} else {
	    int i;
	    for (i = 0; i < n && i < outleft; i++) {
		d[i] = s[i];
	    }
	    d += i;
	    outleft -= i;
	}

	s += n;
	inleft -= n;
	n = hangul_syllable_len(s, inleft);
    }

    return destlen - outleft;
}
