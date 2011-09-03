/* libhangul
 * Copyright (C) 2005-2009 Choe Hwanjin
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

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#ifdef HAVE_MMAP
#include <sys/mman.h>
#endif

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hangul.h"
#include "hangulinternals.h"

#ifndef TRUE
#define TRUE  1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/**
 * @defgroup hanjadictionary 한자 사전 검색 기능
 *
 * @section hanjadictionaryusage 한자 사전 루틴의 사용 방법
 * libhangul에서는 한자 사전 파일과 그 사전 파일을 검색할 수 있는 몇가지
 * 함수의 셋을 제공한다. 여기에서 사용되는 모든 스트링은 UTF-8 인코딩을 
 * 사용한다. libhangul에서 사용하는 한자 사전 파일의 포맷은
 * @ref HanjaTable 섹션을 참조한다.
 * 
 * 그 개략적인 사용 방법은 다음과 같다.
 *
 * @code
    // 지정된 위치의 한자 사전 파일을 로딩한다.
    // 아래 코드에서는 libhangul의 한자 사전 파일을 로딩하기 위해서
    // NULL을 argument로 준다.
    HanjaTable* table = hanja_table_load(NULL);

    // "삼국사기"에 해당하는 한자를 찾는다.
    HanjaList* list = hanja_table_match_exact(table, "삼국사기");
    if (list != NULL) {
	int i;
	int n = hanja_list_get_size(list);
	for (i = 0; i < n; ++i) {
	    const char* hanja = hanja_list_get_nth_value(list);
	    printf("한자: %s\n", hanja);
	}
	hanja_list_delete(list);
    }
    
    hanja_table_delete(table);

 * @endcode
 */

/**
 * @file hanja.c
 */

/**
 * @ingroup hanjadictionary
 * @typedef Hanja
 * @brief 한자 사전 검색 결과의 최소 단위
 *
 * Hanja 오브젝트는 한자 사전 파일의 각 엔트리에 해당한다.
 * 각 엔트리는 키(key), 밸류(value) 페어로 볼 수 있는데, libhangul에서는
 * 약간 확장을 하여 설명(comment)도 포함하고 있다.
 * 한자 사전 포맷은 @ref HanjaTable 부분을 참조한다.
 *
 * 한자 사전을 검색하면 결과는 Hanja 오브젝트의 리스트 형태로 전달된다.
 * @ref HanjaList에서 각 엔트리의 내용을 하나씩 확인할 수 있다.
 * Hanja의 멤버는 직접 참조할 수 없고, hanja_get_key(), hanja_get_value(),
 * hanja_get_comment() 함수로 찾아볼 수 있다.
 * char 스트링으로 전달되는 내용은 모두 UTF-8 인코딩으로 되어 있다.
 */

/**
 * @ingroup hanjadictionary
 * @typedef HanjaList
 * @brief 한자 사전의 검색 결과를 전달하는데 사용하는 오브젝트
 *
 * 한자 사전의 검색 함수를 사용하면 이 타입으로 결과를 리턴한다. 
 * 이 오브젝트에서 hanja_list_get_nth()함수를 이용하여 검색 결과를
 * 이터레이션할 수 있다.  내부 구현 내용은 외부로 노출되어 있지 않다.
 * @ref HanjaList가 가지고 있는 아이템들은 accessor 함수들을 이용해서 참조한다.
 *
 * 참조: hanja_list_get_nth(), hanja_list_get_nth_key(),
 * hanja_list_get_nth_value(), hanja_list_get_nth_comment()
 */

/**
 * @ingroup hanjadictionary
 * @typedef HanjaTable
 * @brief 한자 사전을 관리하는데 사용하는 오브젝트
 *
 * libhangul에서 한자 사전을 관리하는데 사용하는 오브젝트로
 * 내부 구현 내용은 외부로 노출되어 있지 않다.
 *
 * libhangul에서 사용하는 한자 사전 파일의 포맷은 다음과 같은 형식이다.
 *
 * @code
 * # comment
 * key1:value1:comment1
 * key2:value2:comment2
 * key3:value3:comment3
 * ...
 * @endcode
 *
 * 각 필드는 @b @c : 으로 구분하고, 첫번째 필드는 각 한자를 찾을 키값이고 
 * 두번째 필드는 그 키값에 해당하는 한자 스트링, 세번째 필드는 이 키와
 * 값에 대한 설명이다. #으로 시작하는 라인은 주석으로 무시된다.
 *
 * 실제 예를 들면 다음과 같은 식이다.
 *
 * @code
 * 삼국사기:三國史記:삼국사기
 * 한자:漢字:한자
 * @endcode
 * 
 * 그 내용은 키값에 대해서 sorting 되어야 있어야 한다.
 * 파일의 인코딩은 UTF-8이어야 한다.
 */

typedef struct _HanjaIndex     HanjaIndex;

typedef struct _HanjaPair      HanjaPair;
typedef struct _HanjaPairArray HanjaPairArray;

struct _Hanja {
    uint32_t key_offset;
    uint32_t value_offset;
    uint32_t comment_offset;
};

struct _HanjaList {
    char*         key;
    size_t        len;
    size_t        alloc;
    const Hanja** items; 
};

struct _HanjaIndex {
    unsigned offset;
    char     key[8];
};

struct _HanjaTable {
    HanjaIndex*    keytable;
    unsigned       nkeys;
    unsigned       key_size;
    FILE*          file;
};

struct _HanjaPair {
    ucschar first;
    ucschar second;
};

struct _HanjaPairArray {
    ucschar          key;
    const HanjaPair* pairs;
};

#include "hanjacompatible.h"

static const char utf8_skip_table[256] = {
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,5,5,5,5,6,6,1,1
};

static inline int utf8_char_len(const char *p)
{
    return utf8_skip_table[*(const unsigned char*)p];
}

static inline const char* utf8_next(const char *str)
{
    int n = utf8_char_len(str);

    while (n > 0) {
	str++;
	if (*str == '\0')
	    return str;
	n--;
    }

    return str;
}

static inline char* utf8_prev(const char *str, const char *p)
{
    for (--p; p >= str; --p) {
	if ((*p & 0xc0) != 0x80)
	    break;
    }
    return (char*)p;
}

/* hanja searching functions */
static Hanja *
hanja_new(const char *key, const char *value, const char *comment)
{
    Hanja* hanja;
    size_t size;
    size_t keylen;
    size_t valuelen;
    size_t commentlen;
    char*  p;

    keylen = strlen(key) + 1;
    valuelen = strlen(value) + 1;
    if (comment != NULL)
	commentlen = strlen(comment) + 1;
    else
	commentlen = 1;

    size = sizeof(*hanja) + keylen + valuelen + commentlen;
    hanja = malloc(size);
    if (hanja == NULL)
	return NULL;

    p = (char*)hanja + sizeof(*hanja);
    strcpy(p, key);
    p += keylen;
    strcpy(p, value);
    p += valuelen;
    if (comment != NULL)
	strcpy(p, comment);
    else
	*p = '\0';
    p += valuelen;

    hanja->key_offset     = sizeof(*hanja);
    hanja->value_offset   = sizeof(*hanja) + keylen;
    hanja->comment_offset = sizeof(*hanja) + keylen + valuelen;

    return hanja;
}

static void
hanja_delete(Hanja* hanja)
{
    free(hanja);
}

/**
 * @ingroup hanjadictionary
 * @brief @ref Hanja의 키를 찾아본다.
 * @return @a hanja 오브젝트의 키, UTF-8
 *
 * 일반적으로 @ref Hanja 아이템의 키는 한글이다.
 * 리턴되는 스트링은 @a hanja 오브젝트 내부적으로 관리하는 데이터로
 * 수정하거나 free 되어서는 안된다.
 */
const char*
hanja_get_key(const Hanja* hanja)
{
    if (hanja != NULL) {
	const char* p  = (const char*)hanja;
	return p + hanja->key_offset;
    }
    return NULL;
}

/**
 * @ingroup hanjadictionary
 * @brief @ref Hanja의 값을 찾아본다.
 * @return @a hanja 오브젝트의 값, UTF-8
 *
 * 일반적으로 @ref Hanja 아이템의 값은 key에 대응되는 한자다.
 * 리턴되는 스트링은 @a hanja 오브젝트 내부적으로 관리하는 데이터로
 * 수정하거나 free되어서는 안된다.
 */
const char*
hanja_get_value(const Hanja* hanja)
{
    if (hanja != NULL) {
	const char* p  = (const char*)hanja;
	return p + hanja->value_offset;
    }
    return NULL;
}

/**
 * @ingroup hanjadictionary
 * @brief @ref Hanja의 설명을 찾아본다.
 * @return @a hanja 오브젝트의 comment 필드, UTF-8
 *
 * 일반적으로 @ref Hanja 아이템의 설명은 한글과 그 한자에 대한 설명이다.
 * 파일에 따라서 내용이 없을 수 있다.
 * 리턴되는 스트링은 @a hanja 오브젝트 내부적으로 관리하는 데이터로
 * 수정하거나 free되어서는 안된다.
 */
const char*
hanja_get_comment(const Hanja* hanja)
{
    if (hanja != NULL) {
	const char* p  = (const char*)hanja;
	return p + hanja->comment_offset;
    }
    return NULL;
}

static HanjaList *
hanja_list_new(const char *key)
{
    HanjaList *list;

    list = malloc(sizeof(*list));
    if (list != NULL) {
	list->key = strdup(key);
	list->len = 0;
	list->alloc = 1;
	list->items = malloc(list->alloc * sizeof(list->items[0]));
	if (list->items == NULL) {
	    free(list);
	    list = NULL;
	}
    }

    return list;
}

static void
hanja_list_reserve(HanjaList* list, size_t n)
{
    size_t size = list->alloc;

    if (n > SIZE_MAX / sizeof(list->items[0]) - list->len)
	return;

    while (size < list->len + n)
	size *= 2;

    if (size > SIZE_MAX / sizeof(list->items[0]))
	return;

    if (list->alloc < list->len + n) {
	const Hanja** data;

	data = realloc(list->items, size * sizeof(list->items[0]));
	if (data != NULL) {
	    list->alloc = size;
	    list->items = data;
	}
    }
}

static void
hanja_list_append_n(HanjaList* list, const Hanja* hanja, int n)
{
    hanja_list_reserve(list, n);

    if (list->alloc >= list->len + n) {
	unsigned int i;
	for (i = 0; i < n ; i++)
	    list->items[list->len + i] = hanja + i;
	list->len += n;
    }
}

static void
hanja_table_match(const HanjaTable* table,
		  const char* key, HanjaList** list)
{
    int low, high, mid;
    int res = -1;

    low = 0;
    high = table->nkeys - 1;

    while (low < high) {
	mid = (low + high) / 2;
	res = strncmp(table->keytable[mid].key, key, table->key_size);
	if (res < 0) {
	    low = mid + 1;
	} else if (res > 0) {
	    high = mid - 1;
	} else {
	    break;
	}
    }

    if (res != 0) {
	mid = low;
	res = strncmp(table->keytable[mid].key, key, table->key_size);
    }

    if (res == 0) {
	unsigned offset;
	char buf[512];

	offset = table->keytable[mid].offset;
	fseek(table->file, offset, SEEK_SET);

	while (fgets(buf, sizeof(buf), table->file) != NULL) {
	    char* save = NULL;
	    char* p = strtok_r(buf, ":", &save);
	    res = strcmp(p, key);
	    if (res == 0) {
		char* value   = strtok_r(NULL, ":", &save);
		char* comment = strtok_r(NULL, "\r\n", &save);

		Hanja* hanja = hanja_new(p, value, comment);

		if (*list == NULL) {
		    *list = hanja_list_new(key);
		}

		hanja_list_append_n(*list, hanja, 1);
	    } else if (res > 0) {
		break;
	    }
	}
    }
}

/**
 * @ingroup hanjadictionary
 * @brief 한자 사전 파일을 로딩하는 함수
 * @param filename 로딩할 사전 파일의 위치, 또는 NULL
 * @return 한자 사전 object 또는 NULL
 *
 * 이 함수는 한자 사전 파일을 로딩하는 함수로 @a filename으로 지정된 
 * 파일을 로딩한다. 한자 사전 파일은 libhangul에서 사용하는 포맷이어야 한다.
 * 한자 사전 파일의 포맷에 대한 정보는 HanjaTable을 참조한다.
 * 
 * @a filename은 locale에 따른 인코딩으로 되어 있어야 한다. UTF-8이 아닐 수
 * 있으므로 주의한다.
 * 
 * @a filename 에 NULL을 주면 libhangul에서 디폴트로 배포하는 사전을 로딩한다.
 * 파일이 없거나, 포맷이 맞지 않으면 로딩에 실패하고 NULL을 리턴한다.
 * 한자 사전이 더이상 필요없으면 hanja_table_delete() 함수로 삭제해야 한다.
 */
HanjaTable*
hanja_table_load(const char* filename)
{
    unsigned nkeys;
    char buf[512];
    int key_size = 5;
    char last_key[8] = { '\0', };
    char* save_ptr = NULL;
    char* key;
    long offset;
    unsigned i;
    FILE* file;
    HanjaIndex* keytable;
    HanjaTable* table;

    if (filename == NULL)
	filename = LIBHANGUL_DEFAULT_HANJA_DIC;

    file = fopen(filename, "r");
    if (file == NULL) {
	return NULL;
    }

    nkeys = 0;
    while (fgets(buf, sizeof(buf), file) != NULL) {
	/* skip comments and empty lines */
	if (buf[0] == '#' || buf[0] == '\r' || buf[0] == '\n' || buf[0] == '\0')
	    continue;

	save_ptr = NULL;
	key = strtok_r(buf, ":", &save_ptr);

	if (key == NULL || strlen(key) == 0)
	    continue;

	if (strncmp(last_key, key, key_size) != 0) {
	    nkeys++;
	    strncpy(last_key, key, key_size);
	}
    }

    rewind(file);
    keytable = malloc(nkeys * sizeof(keytable[0]));
    memset(keytable, 0, nkeys * sizeof(keytable[0]));

    i = 0;
    offset = ftell(file);
    while (fgets(buf, sizeof(buf), file) != NULL) {
	/* skip comments and empty lines */
	if (buf[0] == '#' || buf[0] == '\r' || buf[0] == '\n' || buf[0] == '\0')
	    continue;

	save_ptr = NULL;
	key = strtok_r(buf, ":", &save_ptr);

	if (key == NULL || strlen(key) == 0)
	    continue;

	if (strncmp(last_key, key, key_size) != 0) {
	    keytable[i].offset = offset;
	    strncpy(keytable[i].key, key, key_size);
	    strncpy(last_key, key, key_size);
	    i++;
	}
	offset = ftell(file);
    }

    table = malloc(sizeof(*table));
    if (table == NULL) {
	free(keytable);
	fclose(file);
	return NULL;
    }

    table->keytable = keytable;
    table->nkeys = nkeys;
    table->key_size = key_size;
    table->file = file;

    return table;
}

/**
 * @ingroup hanjadictionary
 * @brief 한자 사전 object를 free하는 함수
 * @param table free할 한자 사전 object
 */
void
hanja_table_delete(HanjaTable *table)
{
    if (table != NULL) {
	free(table->keytable);
	fclose(table->file);
	free(table);
    }
}

/**
 * @ingroup hanjadictionary
 * @brief 한자 사전에서 매치되는 키를 가진 엔트리를 찾는 함수
 * @param table 한자 사전 object
 * @param key 찾을 키, UTF-8 인코딩
 * @return 찾은 결과를 HanjaList object로 리턴한다. 찾은 것이 없거나 에러가 
 *         있으면 NULL을 리턴한다.
 *
 * @a key 값과 같은 키를 가진 엔트리를 검색한다.
 * 리턴된 결과는 다 사용하고 나면 반드시 hanja_list_delete() 함수로 free해야
 * 한다.
 */
HanjaList*
hanja_table_match_exact(const HanjaTable* table, const char *key)
{
    HanjaList* ret = NULL;

    if (key == NULL || key[0] == '\0' || table == NULL)
	return NULL;

    hanja_table_match(table, key, &ret);

    return ret;
}

/**
 * @ingroup hanjadictionary
 * @brief 한자 사전에서 앞부분이 매치되는 키를 가진 엔트리를 찾는 함수
 * @param table 한자 사전 object
 * @param key 찾을 키, UTF-8 인코딩
 * @return 찾은 결과를 HanjaList object로 리턴한다. 찾은 것이 없거나 에러가 
 *         있으면 NULL을 리턴한다.
 *
 * @a key 값과 같거나 앞부분이 같은 키를 가진 엔트리를 검색한다.
 * 그리고 key를 뒤에서부터 한자씩 줄여가면서 검색을 계속한다.
 * 예로 들면 "삼국사기"를 검색하면 "삼국사기", "삼국사", "삼국", "삼"을 
 * 각각 모두 검색한다.
 * 리턴된 결과는 다 사용하고 나면 반드시 hanja_list_delete() 함수로 free해야
 * 한다.
 */
HanjaList*
hanja_table_match_prefix(const HanjaTable* table, const char *key)
{
    char* p;
    char* newkey;
    HanjaList* ret = NULL;

    if (key == NULL || key[0] == '\0' || table == NULL)
	return NULL;

    newkey = strdup(key);
    if (newkey == NULL)
	return NULL;

    p = strchr(newkey, '\0');
    while (newkey[0] != '\0') {
	hanja_table_match(table, newkey, &ret);
	p = utf8_prev(newkey, p);
	p[0] = '\0';
    }
    free(newkey);

    return ret;
}

/**
 * @ingroup hanjadictionary
 * @brief 한자 사전에서 뒷부분이 매치되는 키를 가진 엔트리를 찾는 함수
 * @param table 한자 사전 object
 * @param key 찾을 키, UTF-8 인코딩
 * @return 찾은 결과를 HanjaList object로 리턴한다. 찾은 것이 없거나 에러가 
 *         있으면 NULL을 리턴한다.
 *
 * @a key 값과 같거나 뒷부분이 같은 키를 가진 엔트리를 검색한다.
 * 그리고 key를 앞에서부터 한자씩 줄여가면서 검색을 계속한다.
 * 예로 들면 "삼국사기"를 검색하면 "삼국사기", "국사기", "사기", "기"를 
 * 각각 모두 검색한다.
 * 리턴된 결과는 다 사용하고 나면 반드시 hanja_list_delete() 함수로 free해야
 * 한다.
 */
HanjaList*
hanja_table_match_suffix(const HanjaTable* table, const char *key)
{
    const char* p;
    HanjaList* ret = NULL;

    if (key == NULL || key[0] == '\0' || table == NULL)
	return NULL;

    p = key;
    while (p[0] != '\0') {
	hanja_table_match(table, p, &ret);
	p = utf8_next(p);
    }

    return ret;
}

/**
 * @ingroup hanjadictionary
 * @brief @ref HanjaList가 가지고 있는 아이템의 갯수를 구하는 함수
 */
int
hanja_list_get_size(const HanjaList *list)
{
    if (list != NULL)
	return list->len;
    return 0;
}

/**
 * @ingroup hanjadictionary
 * @brief @ref HanjaList가 생성될때 검색함수에서 사용한 키를 구하는 함수
 * @return @ref HanjaList의 key 스트링
 *
 * 한자 사전 검색 함수로 HanjaList를 생성하면 HanjaList는 그 검색할때 사용한
 * 키를 기억하고 있다. 이 값을 확인할때 사용한다.
 * 주의할 점은, 각 Hanja 아이템들은 각각의 키를 가지고 있지만, 이것이
 * 반드시 @ref HanjaList와 일치하지는 않는다는 것이다.
 * 검색할 당시에 사용한 함수가 prefix나 suffix계열이면 더 짧은 키로도 
 * 검색하기 때문에 @ref HanjaList의 키와 검색 결과의 키와 다른 것들도 
 * 가지고 있게 된다.
 *
 * 리턴된 스트링 포인터는 @ref HanjaList에서 관리하는 스트링으로
 * 수정하거나 free해서는 안된다.
 */
const char*
hanja_list_get_key(const HanjaList *list)
{
    if (list != NULL)
	return list->key;
    return NULL;
}

/**
 * @ingroup hanjadictionary
 * @brief @ref HanjaList 의 n번째 @ref Hanja 아이템의 포인터를 구하는 함수
 * @param list @ref HanjaList를 가리키는 포인터
 * @param n 참조할 아이템의 인덱스
 * @return @ref Hanja를 가리키는 포인터
 * 
 * 이 함수는 @a list가 가리키는 @ref HanjaList의 n번째 @ref Hanja 오브젝트를
 * 가리키는 포인터를 리턴한다.
 * @ref HanjaList 의 각 아이템은 정수형 인덱스로 각각 참조할 수 있다.
 * @ref HanjaList 가 가진 엔트리 갯수를 넘어서는 인덱스를 주면 NULL을 리턴한다.
 * 리턴된 @ref Hanja 오브젝트는 @ref HanjaList가 관리하는 오브젝트로 free하거나
 * 수정해서는 안된다.
 *
 * 다음의 예제는 list로 주어진 @ref HanjaList 의 모든 값을 프린트 하는 
 * 코드다.
 * 
 * @code
 * int i;
 * int n = hanja_list_get_size(list);
 * for (i = 0; i < n; i++) {
 *	Hanja* hanja = hanja_list_get_nth(i);
 *	const char* value = hanja_get_value(hanja);
 *	printf("Hanja: %s\n", value);
 *	// 또는 hanja에서 다른 정보를 참조하거나
 *	// 다른 작업을 할 수도 있다.
 * }
 * @endcode
 */
const Hanja*
hanja_list_get_nth(const HanjaList *list, unsigned int n)
{
    if (list != NULL) {
	if (n < list->len)
	    return list->items[n];
    }
    return NULL;
}

/**
 * @ingroup hanjadictionary
 * @brief @ref HanjaList 의 n번째 아이템의 키를 구하는 함수
 * @return n번째 아이템의 키, UTF-8
 *
 * HanjaList_get_nth()의 convenient 함수
 */
const char*
hanja_list_get_nth_key(const HanjaList *list, unsigned int n)
{
    const Hanja* hanja = hanja_list_get_nth(list, n);
    return hanja_get_key(hanja);
}

/**
 * @ingroup hanjadictionary
 * @brief @ref HanjaList의 n번째 아이템의 값를 구하는 함수
 * @return n번째 아이템의 값(value), UTF-8
 *
 * HanjaList_get_nth()의 convenient 함수
 */
const char*
hanja_list_get_nth_value(const HanjaList *list, unsigned int n)
{
    const Hanja* hanja = hanja_list_get_nth(list, n);
    return hanja_get_value(hanja);
}

/**
 * @ingroup hanjadictionary
 * @brief @ref HanjaList의 n번째 아이템의 설명을 구하는 함수
 * @return n번째 아이템의 설명(comment), UTF-8
 *
 * HanjaList_get_nth()의 convenient 함수
 */
const char*
hanja_list_get_nth_comment(const HanjaList *list, unsigned int n)
{
    const Hanja* hanja = hanja_list_get_nth(list, n);
    return hanja_get_comment(hanja);
}

/**
 * @ingroup hanjadictionary
 * @brief 한자 사전 검색 함수가 리턴한 결과를 free하는 함수
 * @param list free할 @ref HanjaList
 *
 * libhangul의 모든 한자 사전 검색 루틴이 리턴한 결과는 반드시
 * 이 함수로 free해야 한다.
 */
void
hanja_list_delete(HanjaList *list)
{
    if (list) {
	size_t i;
	for (i = 0; i < list->len; i++) {
	    hanja_delete((Hanja*)list->items[i]);
	}
	free(list->items);
	free(list->key);
	free(list);
    }
}

static int
compare_pair(const void* a, const void* b)
{
    const ucschar*   c = a;
    const HanjaPair* y = b;

    return *c - y->first;
}

size_t
hanja_compatibility_form(ucschar* hanja, const ucschar* hangul, size_t n)
{
    size_t i;
    size_t nconverted;

    if (hangul == NULL || hanja == NULL)
	return 0;

    nconverted = 0;
    for (i = 0; i < n && hangul[i] != 0 && hanja[i] != 0; i++) {
	HanjaPairArray* p;

	p = bsearch(&hanja[i],
		    hanja_unified_to_compat_table,
		    N_ELEMENTS(hanja_unified_to_compat_table),
		    sizeof(hanja_unified_to_compat_table[0]),
		    compare_pair);
	if (p != NULL) {
	    const HanjaPair* pair = p->pairs;
	    while (pair->first != 0) {
		if (pair->first == hangul[i]) {
		    hanja[i] = pair->second;
		    nconverted++;
		    break;
		}
		pair++;
	    }
	}
    }

    return nconverted;
}

size_t
hanja_unified_form(ucschar* str, size_t n)
{
    size_t i;
    size_t nconverted;

    if (str == NULL)
	return 0;

    nconverted = 0;
    for (i = 0; i < n && str[i] != 0; i++) {
	if (str[i] >= 0xF900 && str[i] <= 0xFA0B) {
	    str[i] = hanja_compat_to_unified_table[str[i] - 0xF900];
	    nconverted++;
	}
    }

    return nconverted;
}
