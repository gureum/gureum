//
//  util.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 7..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#ifndef __HANGEUL_UTIL__
#define __HANGEUL_UTIL__

#include <stdint.h>

namespace hangeul {
    struct Empty { static Empty empty() { Empty empty; return empty; } };
    template <typename T> struct Optional {
        union {
            struct {} none;
            T some;
        };
        bool is_none;

        T& unwrap() { return this->some; }
        static Optional<T> None() { Optional<T> value; value.is_none = true; return value; }
        static Optional<T> Some(T& some) { Optional<T> value; value.some = some; value.is_none= false; return value; }
    };
}

#endif // __HANGEUL_UTIL__