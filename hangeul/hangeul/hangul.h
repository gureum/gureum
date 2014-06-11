//
//  hangul.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 9..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __HANGEUL_HANGUL__
#define __HANGEUL_HANGUL__

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

    /**/
    void *_context();
    uint32_t _put(void *context, uint32_t input);
    uint32_t _state(void *context);
    uint32_t _flush(void *context);
#ifdef __cplusplus
}
#endif

#endif