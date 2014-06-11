//
//  decoder.h
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 9..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#include <hangeul/type.h>

namespace hangeul {
    class Decoder {
        virtual UnicodeVector decode(State state) = 0;
    };
}