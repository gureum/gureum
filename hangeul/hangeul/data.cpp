//
//  data.cpp
//  hangeul
//
//  Created by Jeong YunWon on 2014. 6. 9..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

#include <hangeul/data.h>

namespace hangeul {
    namespace Initial {
        Initial::Type None = (Initial::Type)0;
        Initial::Type FromConsonant[31] = {
            None,
            G,
            GG,
            None,
            N,
            None,
            None,
            D,
            DD,
            R,
            None,
            None,
            None,
            None,
            None,
            None,
            None,
            M,
            B,
            BB,
            None,
            S,
            SS,
            NG,
            J,
            JJ,
            CH,
            K,
            T,
            P,
            H,
        };
    }

    namespace Final {
        Final::Type None = (Final::Type)0;
        Final::Type FromConsonant[31] = {
            None,
            G,
            GG,
            GS,
            N,
            NJ,
            NH,
            D,
            None,
            R,
            RG,
            RM,
            RB,
            RS,
            RT,
            RP,
            RH,
            M,
            B,
            None,
            BS,
            S,
            SS,
            NG,
            J,
            None,
            CH,
            K,
            T,
            P,
            H,
        };
    };
}